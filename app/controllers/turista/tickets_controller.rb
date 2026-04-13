class Turista::TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: [:show, :download, :mark_as_used]
  before_action :set_event, only: [:new_free, :create_free]
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
    if @ticket.activa?
      @ticket.mark_as_used!
      redirect_to turista_ticket_path(@ticket), notice: "Ticket marcado como usado."
    else
      redirect_to turista_ticket_path(@ticket), alert: "Este ticket ya fue usado o está cancelado."
    end
  end

  def new_free
    if @event.ticket_price.to_f > 0
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
    if @event.ticket_price.to_f > 0
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
end
