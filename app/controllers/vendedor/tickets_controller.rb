class Vendedor::TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_vendedor!
  before_action :set_event
  before_action :set_ticket, only: [:acreditar, :rechazar]
  before_action :set_bulk_tickets, only: [:bulk_acreditar, :bulk_rechazar]
  layout "dashboard"

  def index
    @all_tickets = @event.tickets.where(vendedor: current_user)
    @buyers      = @all_tickets.distinct.order(:guest_name).pluck(:guest_name).compact.reject(&:blank?)
    @codes       = @all_tickets.order(:ticket_code).pluck(:ticket_code).compact

    @tickets = @all_tickets.order(created_at: :desc)
    @tickets = @tickets.where(status: params[:status])         if params[:status].present?
    @tickets = @tickets.where(guest_name: params[:buyer])      if params[:buyer].present?
    @tickets = @tickets.where(ticket_code: params[:code])      if params[:code].present?
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

  def bulk_acreditar
    acreditados = 0
    @bulk_tickets.each do |ticket|
      next unless ticket.reservado?
      ticket.acreditar!
      begin
        TicketMailer.ticket_acreditado(ticket.user, ticket).deliver_later
      rescue => e
        Rails.logger.error("Error enviando email de acreditación: #{e.message}")
      end
      acreditados += 1
    end
    redirect_to vendedor_event_tickets_path(@event),
                notice: "#{acreditados} #{'ticket'.pluralize(acreditados)} acreditado#{'s' if acreditados != 1} exitosamente."
  end

  def bulk_rechazar
    rechazados = 0
    @bulk_tickets.each do |ticket|
      next unless ticket.reservado?
      ticket.rechazar!
      rechazados += 1
    end
    redirect_to vendedor_event_tickets_path(@event),
                notice: "#{rechazados} #{'ticket'.pluralize(rechazados)} rechazado#{'s' if rechazados != 1}."
  end

  private

  def set_event
    @event = current_user.vendedor_events.find(params[:event_id])
  end

  def set_ticket
    @ticket = @event.tickets.where(vendedor: current_user).find(params[:id])
  end

  def set_bulk_tickets
    ids = Array(params[:ticket_ids])
    if ids.blank?
      redirect_to vendedor_event_tickets_path(@event), alert: "No seleccionaste ningún ticket."
      return
    end
    @bulk_tickets = @event.tickets.where(vendedor: current_user, id: ids)
  end
end
