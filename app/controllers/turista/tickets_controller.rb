class Turista::TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: [:show, :download, :mark_as_used, :check_status]
  before_action :set_event, only: [:new_free, :create_free, :new_purchase, :create_purchase, :new_transfer, :create_transfer, :transfer_status]
  layout "dashboard"

  def index
    @tickets = current_user.tickets.order(created_at: :desc)

    # Filtros
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    @tickets = @tickets.for_event(params[:event]) if params[:event].present?
  end

  def show
  end

  def download
    pdf_service = TicketPdfService.new(@ticket)
    pdf_data = pdf_service.generate

    send_data pdf_data,
      filename: "ticket_#{@ticket.ticket_code}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end

  def mark_as_used
    if @ticket.activo?
      @ticket.mark_as_used!
      redirect_to turista_ticket_path(@ticket), notice: "Ticket marcado como usado."
    else
      redirect_to turista_ticket_path(@ticket), alert: "Este ticket ya fue usado o está cancelado."
    end
  end

  def new_free
    if @event.price_for(current_user) > 0
      redirect_to events_path, alert: "Este evento requiere pago."
      return
    end

    if @event.sold_out?
      redirect_to events_path, alert: "No hay tickets disponibles para este evento."
      return
    end

    @ticket = current_user.tickets.build(
      event: @event,
      event_name: @event.name,
      event_date: @event.event_date,
      event_location: @event.location,
      unit_price: 0,
      total_price: 0,
      guest_name: current_user.name,
      guest_email: current_user.email
    )
  end

  def create_free
    if @event.price_for(current_user) > 0
      redirect_to events_path, alert: "Este evento requiere pago."
      return
    end

    if @event.sold_out?
      redirect_to events_path, alert: "No hay tickets disponibles para este evento."
      return
    end

    service = TicketGeneratorService.new(
      current_user,
      ticket_params: {
        event_name: @event.name,
        event_date: @event.event_date,
        event_location: @event.location,
        unit_price: 0,
        quantity: 1,
        guest_name: ticket_params[:guest_name] || current_user.name,
        guest_email: ticket_params[:guest_email] || current_user.email,
        guest_phone: current_user.phone
      }
    )

    result = service.call

    if result[:success]
      # Decrementar tickets disponibles
      @event.decrement!(:available_tickets) if @event.available_tickets.present?
      redirect_to turista_tickets_path, notice: "¡Ticket gratuito adquirido exitosamente! Revisa tu email."
    else
      redirect_to new_free_turista_event_tickets_path(@event), alert: "Error: #{result[:error]}"
    end
  end

  # --- Flujo unificado de compra ---

  def new_purchase
    if @event.price_for(current_user) == 0
      redirect_to new_free_turista_event_tickets_path(@event), notice: "Este evento es gratuito."
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
      redirect_to events_path, alert: "No hay tickets disponibles."
      return
    end

    case params[:payment_method]
    when "tarjeta"
      create_payphone_ticket
    when "transferencia"
      create_transfer_ticket
    else
      redirect_to new_purchase_turista_event_tickets_path(@event), alert: "Selecciona un método de pago."
    end
  end

  # --- Flujo de Transferencia (redirige a flujo unificado) ---

  def new_transfer
    redirect_to new_purchase_turista_event_tickets_path(@event)
  end

  def create_transfer
    create_transfer_ticket
  end

  def transfer_status
    @ticket = current_user.tickets.find(params[:ticket_id])
    @vendedor = @ticket.vendedor

    message = "Hola, soy #{current_user.name}. " \
              "Acabo de reservar un ticket para el evento #{@event.name} " \
              "(Código: #{@ticket.ticket_code}). " \
              "Precio: $#{@event.price_for(current_user)}. " \
              "Por favor confirmar el pago por transferencia."
    @whatsapp_url = helpers.whatsapp_link(@vendedor.phone, message)
  end

  def check_status
    render json: {
      status: @ticket.status,
      time_remaining: @ticket.time_remaining
    }
  end

  private

  def set_ticket
    @ticket = current_user.tickets.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ticket_params
    params.require(:ticket).permit(:guest_name, :guest_email, :guest_phone)
  end


  def create_payphone_ticket
    guest_name = params[:guest_name].presence || current_user.name
    guest_email = params[:guest_email].presence || current_user.email
    quantity = [params[:quantity].to_i, 1].max

    # Verificar disponibilidad
    if @event.available_tickets.present? && quantity > @event.available_tickets
      redirect_to new_purchase_turista_event_tickets_path(@event),
                  alert: "No hay suficientes tickets disponibles. Solo quedan #{@event.available_tickets}."
      return
    end

    # NO crear tickets aún — se crean solo cuando PayPhone confirma el pago
    unit_price  = @event.price_for(current_user)
    total_price = @event.total_price_for(current_user, quantity)
    @amount_cents = (total_price * 100).to_i
    @client_transaction_id = "IYAI-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}"
    @reference = "#{quantity} ticket(s) - #{@event.name}"

    @transaction = PayphoneTransaction.create!(
      user: current_user,
      client_transaction_id: @client_transaction_id,
      amount_cents: @amount_cents,
      currency: "USD",
      email: current_user.email,
      phone_number: current_user.phone,
      status: :pendiente,
      metadata: {
        type: "ticket",
        event_id: @event.id,
        quantity: quantity,
        guest_name: guest_name,
        guest_email: guest_email,
        guest_phone: current_user.phone,
        unit_price: unit_price,
        total_price: total_price,
        referral_code: params[:referral_code].to_s.strip.upcase.presence
      }
    )

    @payphone_token = ENV.fetch("PAYPHONE_TOKEN")
    @store_id = ENV.fetch("PAYPHONE_STORE_ID")

    render "payphone/checkout"
  rescue => e
    redirect_to new_purchase_turista_event_tickets_path(@event),
                alert: "Error: #{e.message}"
  end

  def create_transfer_ticket
    vendedor = User.find_by(id: params[:vendedor_id], role: :vendedor)
    unless vendedor
      redirect_to new_purchase_turista_event_tickets_path(@event),
                  alert: "Por favor selecciona un vendedor."
      return
    end

    quantity = [params[:quantity].to_i, 1].max

    # Verificar disponibilidad
    if @event.available_tickets.present? && quantity > @event.available_tickets
      redirect_to new_purchase_turista_event_tickets_path(@event),
                  alert: "No hay suficientes tickets disponibles. Solo quedan #{@event.available_tickets}."
      return
    end

    unit_price  = @event.price_for(current_user)
    total_price = @event.total_price_for(current_user, quantity)
    tickets = []
    ActiveRecord::Base.transaction do
      quantity.times do
        ticket = Ticket.create!(
          user: current_user,
          event: @event,
          vendedor: vendedor,
          event_name: @event.name,
          event_date: @event.event_date,
          event_location: @event.location,
          unit_price: unit_price,
          total_price: total_price,
          guest_name: params[:guest_name].presence || current_user.name,
          guest_email: params[:guest_email].presence || current_user.email,
          guest_phone: current_user.phone,
          status: :reservado,
          payment_method: :transferencia,
          reserved_at: Time.current,
          referral_code: params[:referral_code].to_s.strip.upcase.presence
        )
        tickets << ticket
      end

      @event.decrement!(:available_tickets, quantity) if @event.available_tickets.present?
    end

    tickets.each do |ticket|
      ExpireReservedTicketsJob.set(wait: 10.minutes).perform_later(ticket.id)
    end

    redirect_to transfer_status_turista_event_tickets_path(@event, ticket_id: tickets.first.id),
                notice: "Has reservado #{quantity} ticket(s). Total a pagar: $#{format('%.2f', total_price)}"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_purchase_turista_event_tickets_path(@event),
                alert: "Error al crear tickets: #{e.message}"
  end
end
