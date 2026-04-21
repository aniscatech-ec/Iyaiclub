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
        # Crear tickets desde metadata ANTES de activate_payable
        # (el payable queda nil hasta que se crean los tickets)
        if @transaction.payable.nil? && @transaction.metadata&.dig("type") == "ticket"
          create_ticket_from_metadata(@transaction)
          @transaction.reload  # recargar para obtener el payable recién asignado
        end

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
  rescue => e
    Rails.logger.error("[PayPhone callback] Error inesperado: #{e.class} - #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    redirect_to root_path, alert: "Ocurrió un error procesando el pago. Contacta al soporte si el cobro fue realizado."
  end

  # GET /payphone/cancel?clientTransactionId=YY
  # PayPhone redirige aquí si el usuario cancela el pago
  def cancel
    client_tx_id = params[:clientTransactionId]

    if client_tx_id.present?
      transaction = PayphoneTransaction.find_by(client_transaction_id: client_tx_id)
      if transaction
        transaction.update!(status: :cancelado)

        case transaction.payable
        when Ticket
          # Liberar cupo si el ticket estaba reservado
          transaction.payable.rechazar! if transaction.payable.reservado?
        when Subscription
          # Cancelar la suscripción pendiente para no dejar basura
          transaction.payable.update!(status: :cancelada)
        end
      end
    end

    redirect_to root_path, notice: "El pago fue cancelado. Puedes intentar nuevamente cuando lo desees."
  end

  private

  def format_phone_for_payphone(phone)
    return nil if phone.blank?

    # Solo dígitos
    digits = phone.to_s.gsub(/\D/, '')
    return nil if digits.blank?

    # Ya tiene código de país Ecuador: 593 + 9 dígitos = 12 dígitos
    return digits if digits.start_with?('593') && digits.length == 12

    # Quitar 0 inicial (formato local: 09XXXXXXXX → 9XXXXXXXX)
    digits = digits.delete_prefix('0')

    # Número móvil Ecuador: 9 dígitos (ej: 987654321)
    return nil unless digits.length == 9

    "593#{digits}"
  rescue
    nil
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

    subscribable_type = params[:subscribable_type]
    subscribable_id   = params[:subscribable_id]
    return nil if subscribable_type.blank? || subscribable_id.blank?

    # Cancelar suscripción pendiente anterior para evitar duplicados
    Subscription.where(
      subscribable_type: subscribable_type,
      subscribable_id: subscribable_id,
      status: :pendiente
    ).destroy_all

    subscription = Subscription.new(
      subscribable_type: subscribable_type,
      subscribable_id:   subscribable_id,
      plan_type:         plan_price.id,
      payment_method:    :tarjeta,
      status:            :pendiente
    )

    subscription.save!
    subscription
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Error creando suscripción pendiente: #{e.message}")
    nil
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
      establishment_name = payable.establishment&.name || "Establecimiento"
      "Reserva ##{payable.id} - #{establishment_name}"
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
    meta     = transaction.metadata
    event    = Event.find(meta["event_id"])
    quantity = (meta["quantity"] || 1).to_i

    unit_price = meta["unit_price"].to_f
    tickets = []
    ActiveRecord::Base.transaction do
      quantity.times do
        ticket = Ticket.create!(
          user:           transaction.user,
          event:          event,
          event_name:     event.name,
          event_date:     event.event_date,
          event_location: event.location,
          unit_price:     unit_price,
          total_price:    unit_price,
          guest_name:     meta["guest_name"],
          guest_email:    meta["guest_email"],
          guest_phone:    meta["guest_phone"],
          status:         :activo,
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

  def activate_payable(payable, transaction = @transaction)
    case payable
    when Subscription
      payable.set_dates
      payable.update!(status: :activada)
    when Booking
      payable.update!(status: :confirmado)
    when Ticket
      payable.acreditar! unless payable.activo?
      begin
        quantity = transaction&.metadata&.dig("quantity").to_i
        # Obtener todos los tickets de la transacción (compra múltiple)
        all_tickets = if quantity > 1
                        if payable.user.present?
                          Ticket.where(user: payable.user, event: payable.event, status: :activo)
                                .order(:id).last(quantity)
                        else
                          Ticket.where(user: nil, event: payable.event, status: :activo,
                                       guest_email: payable.guest_email)
                                .order(:id).last(quantity)
                        end
                      else
                        [payable]
                      end

        if payable.user.present?
          TicketMailer.ticket_purchased(payable.user, all_tickets).deliver_later
        else
          TicketMailer.ticket_confirmation_guest(all_tickets).deliver_later
        end
      rescue => e
        Rails.logger.error("Error enviando email de ticket PayPhone: #{e.message}")
      end
    when nil
      Rails.logger.warn("[PayPhone] activate_payable llamado con payable nil")
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
      booking_redirect_path(payable)
    when Ticket
      if payable.user.present?
        turista_ticket_path(payable)
      else
        events_path
      end
    when nil
      # Transacción sin payable (pago rechazado/cancelado para ticket)
      if transaction.metadata&.dig("type") == "ticket"
        event_path(transaction.metadata["event_id"])
      else
        root_path
      end
    else
      root_path
    end
  end

  def booking_redirect_path(booking)
    bookable = booking.bookable
    case bookable
    when Room
      hotel_booking_path(bookable.hotel, booking)
    when Unit
      hotel = bookable.establishment&.hotel
      hotel ? hotel_booking_path(hotel, booking) : root_path
    when Experience
      experience_booking_path(bookable, booking)
    when Lodging
      lodging_booking_path(bookable, booking)
    when Getaway
      getaway_booking_path(bookable, booking)
    else
      root_path
    end
  end

  def payment_summary(transaction)
    "Transacción ##{transaction.transaction_id} - $#{'%.2f' % transaction.amount_dollars} USD"
  end
end
