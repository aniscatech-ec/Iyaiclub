class PayphoneController < ApplicationController
  before_action :authenticate_user!, except: [:callback, :cancel]
  skip_forgery_protection only: [:callback, :cancel]

  layout "dashboard"

  # POST /payphone/checkout
  # Muestra la vista con la Cajita de Pagos de PayPhone
  def checkout
    @payable = find_payable
    unless @payable
      redirect_back fallback_location: root_path, alert: "No se encontró el recurso para pagar."
      return
    end

    @amount_cents = calculate_amount_cents(@payable)
    @client_transaction_id = generate_client_transaction_id
    @reference = build_reference(@payable)

    # Formatear teléfono al formato internacional que requiere PayPhone
    @formatted_phone = format_phone_for_payphone(current_user.phone)

    @transaction = PayphoneTransaction.create!(
      payable: @payable,
      user: current_user,
      client_transaction_id: @client_transaction_id,
      amount_cents: @amount_cents,
      currency: "USD",
      email: current_user.email,
      phone_number: @formatted_phone,
      status: :pendiente
    )

    @payphone_token = ENV.fetch("PAYPHONE_TOKEN")
    @store_id = ENV.fetch("PAYPHONE_STORE_ID")
  end

  # GET /payphone/callback?id=XX&clientTransactionId=YY
  # PayPhone redirige aquí tras completar el pago
  def callback
    transaction_id = params[:id]
    client_tx_id = params[:clientTransactionId]

    @transaction = PayphoneTransaction.find_by!(client_transaction_id: client_tx_id)

    service = PayphoneService.new
    result = service.confirm(id: transaction_id.to_i, client_tx_id: client_tx_id)

    if result[:success]
      data = result[:data]
      @transaction.update!(
        transaction_id: data["transactionId"],
        status_code: data["statusCode"],
        status: status_from_code(data["statusCode"]),
        authorization_code: data["authorizationCode"],
        card_brand: data["cardBrand"],
        card_last_digits: data["lastDigits"],
        email: data["email"],
        phone_number: data["phoneNumber"],
        response_data: data
      )

      if @transaction.aprobado?
        # Si es una transacción de ticket sin payable, crear el ticket ahora
        create_ticket_from_metadata(@transaction) if @transaction.payable.nil? && @transaction.metadata&.dig("type") == "ticket"

        activate_payable(@transaction.payable)
        redirect_to after_payment_path(@transaction), notice: "Pago realizado exitosamente. #{payment_summary(@transaction)}"
      else
        redirect_to after_payment_path(@transaction), alert: "El pago fue rechazado o cancelado. Intenta nuevamente."
      end
    else
      @transaction.update!(status: :cancelado, response_data: result[:data])
      redirect_to after_payment_path(@transaction), alert: "Error al confirmar el pago: #{result[:error]}"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Transacción no encontrada."
  end

  # GET /payphone/cancel?clientTransactionId=YY
  # PayPhone redirige aquí si el usuario cancela el pago
  def cancel
    client_tx_id = params[:clientTransactionId]

    if client_tx_id.present?
      transaction = PayphoneTransaction.find_by(client_transaction_id: client_tx_id)
      if transaction
        transaction.update!(status: :cancelado)
        # Si el payable es un ticket reservado, rechazarlo para liberar el cupo
        if transaction.payable.is_a?(Ticket) && transaction.payable.reservado?
          transaction.payable.rechazar!
        end
      end
    end

    redirect_to root_path, notice: "El pago fue cancelado. Puedes intentar nuevamente cuando lo desees."
  end

  private

  def format_phone_for_payphone(phone)
    return nil if phone.blank?

    # Limpiar el número (solo dígitos)
    digits = phone.to_s.gsub(/\D/, '')

    # Si ya tiene código de país (más de 10 dígitos), retornar como está
    return digits if digits.length > 10

    # Si empieza con 0, quitarlo (formato local ecuatoriano)
    digits = digits[1..-1] if digits.start_with?('0')

    # Agregar código de país de Ecuador (593)
    "593#{digits}"
  end

  def find_payable
    case params[:payable_type]
    when "Subscription"
      build_subscription
    when "Booking"
      Booking.find_by(id: params[:payable_id])
    when "Ticket"
      Ticket.find_by(id: params[:ticket_id])
    end
  end

  def build_subscription
    plan_price = PlanPrice.find_by(id: params[:plan_price_id])
    return nil unless plan_price

    Subscription.new(
      subscribable_type: params[:subscribable_type],
      subscribable_id: params[:subscribable_id],
      plan_type: plan_price.id,
      payment_method: :tarjeta,
      status: :pendiente
    ).tap(&:save!)
  end

  def calculate_amount_cents(payable)
    case payable
    when Subscription
      plan_price = PlanPrice.find(payable.plan_type)
      (plan_price.price * 100).to_i
    when Booking
      ((payable.total_price || 0) * 100).to_i
    when Ticket
      ((payable.total_price || 0) * 100).to_i
    else
      0
    end
  end

  def generate_client_transaction_id
    "IYAI-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}"
  end

  def build_reference(payable)
    case payable
    when Subscription
      plan_price = PlanPrice.find(payable.plan_type)
      "Suscripción #{plan_price.plan&.name} - #{plan_price.display_duration}"
    when Booking
      "Reserva ##{payable.id} - #{payable.establishment&.name}"
    when Ticket
      "Ticket #{payable.ticket_code} - #{payable.event_name}"
    else
      "Pago IyaiClub"
    end
  end

  def status_from_code(code)
    case code
    when 3 then :aprobado
    when 2 then :cancelado
    else :pendiente
    end
  end

  def create_ticket_from_metadata(transaction)
    meta = transaction.metadata
    event = Event.find(meta["event_id"])
    quantity = meta["quantity"] || 1

    tickets = []
    ActiveRecord::Base.transaction do
      quantity.times do
        ticket = Ticket.create!(
          user: transaction.user,
          event: event,
          event_name: event.name,
          event_date: event.event_date,
          event_location: event.location,
          unit_price: event.ticket_price,
          total_price: event.ticket_price * quantity,
          guest_name: meta["guest_name"],
          guest_email: meta["guest_email"],
          guest_phone: meta["guest_phone"],
          status: :activo,
          payment_method: :payphone
        )
        tickets << ticket
      end

      event.decrement!(:available_tickets, quantity) if event.available_tickets.present?
    end

    # Asociar el primer ticket como payable principal
    transaction.update!(payable: tickets.first)

    tickets
  end

  def activate_payable(payable)
    case payable
    when Subscription
      payable.set_dates
      payable.update!(status: :activada)
    when Booking
      payable.update!(status: :confirmado)
    when Ticket
      payable.acreditar! unless payable.activo?
      begin
        TicketMailer.ticket_purchased(payable.user, [payable]).deliver_later
      rescue => e
        Rails.logger.error("Error enviando email de ticket PayPhone: #{e.message}")
      end
    end
  end

  def after_payment_path(transaction)
    payable = transaction.payable
    case payable
    when Subscription
      if payable.for_tourist?
        turista_dashboard_index_path
      else
        afiliado_dashboard_index_path
      end
    when Booking
      hotel = payable.room&.hotel
      hotel ? hotel_booking_path(hotel, payable) : root_path
    when Ticket
      turista_ticket_path(payable)
    when nil
      # Transacción sin payable (pago rechazado/cancelado para ticket)
      if transaction.metadata&.dig("type") == "ticket"
        event_id = transaction.metadata["event_id"]
        event_path(event_id)
      else
        root_path
      end
    else
      root_path
    end
  end

  def payment_summary(transaction)
    "Transacción ##{transaction.transaction_id} - $#{'%.2f' % transaction.amount_dollars} USD"
  end
end
