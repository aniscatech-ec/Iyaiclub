class Vendedor::TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_vendedor!
  before_action :set_event
  before_action :set_ticket, only: [:acreditar, :rechazar]
  layout "dashboard"

  def index
    @tickets = @event.tickets
                     .where(vendedor: current_user)
                     .order(created_at: :desc)

    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
  end

  def acreditar
    if @ticket.reservado?
      @ticket.acreditar!
      begin
        TicketMailer.ticket_acreditado(@ticket.user, @ticket).deliver_later
      rescue => e
        Rails.logger.error("Error enviando email de acreditación: #{e.message}")
      end
      redirect_to vendedor_event_tickets_path(@event),
                  notice: "Ticket #{@ticket.ticket_code} acreditado exitosamente."
    else
      redirect_to vendedor_event_tickets_path(@event),
                  alert: "Este ticket no puede ser acreditado (estado: #{@ticket.status})."
    end
  end

  def rechazar
    if @ticket.reservado?
      @ticket.rechazar!
      redirect_to vendedor_event_tickets_path(@event),
                  notice: "Ticket #{@ticket.ticket_code} rechazado."
    else
      redirect_to vendedor_event_tickets_path(@event),
                  alert: "Este ticket no puede ser rechazado (estado: #{@ticket.status})."
    end
  end

  private

  def set_event
    @event = current_user.vendedor_events.find(params[:event_id])
  end

  def set_ticket
    @ticket = @event.tickets.where(vendedor: current_user).find(params[:id])
  end
end
