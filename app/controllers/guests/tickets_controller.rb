class Guests::TicketsController < ApplicationController
  before_action :set_event, only: [:new_purchase, :create_purchase, :transfer_status]
  before_action :set_ticket_by_code, only: [:show, :check_status]

  def new_purchase
    if @event.price_for(nil) == 0
      redirect_to event_path(@event), notice: "Este evento es gratuito. Regístrate para obtenerlo."
      return
    end

    if @event.sold_out?
      redirect_to events_path, alert: "No hay tickets disponibles para este evento."
      return
    end

    @vendedores = @event.active_vendedores
  end

  def create_purchase
    if @event.sold_out?
      redirect_to event_path(@event), alert: "No hay tickets disponibles."
      return
    end

    case params[:payment_method]
    when "tarjeta"
      create_payphone_ticket
    when "transferencia"
      create_transfer_ticket
    else
      redirect_to guests_new_purchase_event_tickets_path(@event), alert: "Selecciona un método de pago."
    end
  end

  def transfer_status
    @ticket = Ticket.find_by!(id: params[:ticket_id], user_id: nil)
    @vendedor = @ticket.vendedor

    message = "Hola, soy #{@ticket.guest_name.split('·').first.strip}. " \
              "Acabo de reservar un ticket para el evento #{@event.name} " \
              "(Código: #{@ticket.ticket_code}). " \
              "Precio: $#{@event.price_for(nil)}. " \
              "Por favor confirmar el pago por transferencia."
    @whatsapp_url = helpers.whatsapp_link(@vendedor.phone, message)
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: "Ticket no encontrado."
  end

  def check_status
    render json: {
      status: @ticket.status,
      time_remaining: @ticket.time_remaining
    }
  end

  def show
  end

  def lookup
    if request.post? || params[:code].present?
      code   = params[:code].to_s.strip.upcase
      cedula = params[:cedula].to_s.strip

      @ticket = Ticket.find_by(ticket_code: code)

      if @ticket && @ticket.guest_name.to_s.include?(cedula)
        redirect_to guests_ticket_path(@ticket.ticket_code)
      else
        @error = "No se encontró un ticket con ese código y cédula."
      end
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_ticket_by_code
    @ticket = Ticket.find_by!(ticket_code: params[:code])
  rescue ActiveRecord::RecordNotFound
    redirect_to guests_ticket_lookup_path, alert: "Ticket no encontrado."
  end

  def guest_params
    {
      name:   params[:guest_name].to_s.strip,
      cedula: params[:cedula].to_s.strip,
      email:  params[:guest_email].to_s.strip,
      phone:  params[:guest_phone].to_s.strip
    }
  end

  def formatted_guest_name(name, cedula)
    cedula.present? ? "#{name} · CI: #{cedula}" : name
  end

  def format_phone_for_payphone(phone)
    return nil if phone.blank?

    digits = phone.to_s.gsub(/\D/, "")
    return nil if digits.blank?
    return digits if digits.start_with?("593") && digits.length == 12

    digits = digits.delete_prefix("0")
    return nil unless digits.length == 9

    "593#{digits}"
  rescue StandardError
    nil
  end

  def create_payphone_ticket
    gp       = guest_params
    quantity = [params[:quantity].to_i, 1].max

    if @event.available_tickets.present? && quantity > @event.available_tickets
      redirect_to guests_new_purchase_event_tickets_path(@event),
                  alert: "No hay suficientes tickets. Solo quedan #{@event.available_tickets}."
      return
    end

    guest_name_full = formatted_guest_name(gp[:name], gp[:cedula])
    amount_cents    = (@event.price_for(nil) * 100 * quantity).to_i
    client_tx_id    = "IYAI-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}"
    formatted_phone = format_phone_for_payphone(gp[:phone])

    @transaction = PayphoneTransaction.create!(
      user:                  nil,
      client_transaction_id: client_tx_id,
      amount_cents:          amount_cents,
      currency:              "USD",
      email:                 gp[:email],
      phone_number:          formatted_phone,
      status:                :pendiente,
      metadata: {
        type:        "ticket",
        guest:       true,
        event_id:    @event.id,
        quantity:    quantity,
        guest_name:  guest_name_full,
        guest_email: gp[:email],
        guest_phone: gp[:phone],
        unit_price:  @event.price_for(nil)
      }
    )

    @client_transaction_id = client_tx_id
    @amount_cents          = amount_cents
    @reference             = "#{quantity} ticket(s) - #{@event.name}"
    @payphone_token        = ENV.fetch("PAYPHONE_TOKEN")
    @store_id              = ENV.fetch("PAYPHONE_STORE_ID")

    render "payphone/checkout"
  rescue StandardError => e
    redirect_to guests_new_purchase_event_tickets_path(@event),
                alert: "Error al iniciar el pago: #{e.message}"
  end

  def create_transfer_ticket
    gp       = guest_params
    quantity = [params[:quantity].to_i, 1].max
    vendedor = User.find_by(id: params[:vendedor_id], role: :vendedor)

    unless vendedor
      redirect_to guests_new_purchase_event_tickets_path(@event),
                  alert: "Por favor selecciona un vendedor."
      return
    end

    if @event.available_tickets.present? && quantity > @event.available_tickets
      redirect_to guests_new_purchase_event_tickets_path(@event),
                  alert: "No hay suficientes tickets. Solo quedan #{@event.available_tickets}."
      return
    end

    guest_name_full = formatted_guest_name(gp[:name], gp[:cedula])
    tickets         = []

    ActiveRecord::Base.transaction do
      quantity.times do
        ticket = Ticket.create!(
          user:           nil,
          event:          @event,
          vendedor:       vendedor,
          event_name:     @event.name,
          event_date:     @event.event_date,
          event_location: @event.location,
          unit_price:     @event.price_for(nil),
          total_price:    @event.price_for(nil) * quantity,
          guest_name:     guest_name_full,
          guest_email:    gp[:email],
          guest_phone:    gp[:phone],
          status:         :reservado,
          payment_method: :transferencia,
          reserved_at:    Time.current
        )
        tickets << ticket
      end

      @event.decrement!(:available_tickets, quantity) if @event.available_tickets.present?
    end

    tickets.each { |t| ExpireReservedTicketsJob.set(wait: 10.minutes).perform_later(t.id) }

    redirect_to guests_transfer_status_event_tickets_path(@event, ticket_id: tickets.first.id),
                notice: "Has reservado #{quantity} ticket(s). Total a pagar: $#{format('%.2f', @event.price_for(nil) * quantity)}"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to guests_new_purchase_event_tickets_path(@event),
                alert: "Error al crear la reserva: #{e.message}"
  end
end
