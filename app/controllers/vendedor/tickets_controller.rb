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
    @tickets = @tickets.to_a
  end

  def acreditar
    unless @ticket.reservado?
      redirect_to vendedor_event_tickets_path(@event),
                  alert: "Este ticket no puede ser acreditado (estado: #{@ticket.status})."
      return
    end

    group = same_buyer_pending(@ticket)
    group.each(&:acreditar!)

    begin
      send_acreditado_email(group.first)
    rescue => e
      Rails.logger.error("Error enviando email de acreditación: #{e.message}")
    end

    msg = group.size > 1 ? "#{group.size} tickets de #{@ticket.guest_name.split('·').first.strip} acreditados exitosamente." \
                         : "Ticket #{@ticket.ticket_code} acreditado exitosamente."
    redirect_to vendedor_event_tickets_path(@event), notice: msg
  end

  def rechazar
    unless @ticket.reservado?
      redirect_to vendedor_event_tickets_path(@event),
                  alert: "Este ticket no puede ser rechazado (estado: #{@ticket.status})."
      return
    end

    group = same_buyer_pending(@ticket)
    group.each(&:rechazar!)

    begin
      send_rechazado_email(group.first)
    rescue => e
      Rails.logger.error("Error enviando email de rechazo: #{e.message}")
    end

    msg = group.size > 1 ? "#{group.size} tickets de #{@ticket.guest_name.split('·').first.strip} rechazados." \
                         : "Ticket #{@ticket.ticket_code} rechazado."
    redirect_to vendedor_event_tickets_path(@event), notice: msg
  end

  def bulk_acreditar
    acreditados = 0
    @bulk_tickets.each do |ticket|
      next unless ticket.reservado?
      ticket.acreditar!
      begin
        send_acreditado_email(ticket)
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
      begin
        send_rechazado_email(ticket)
      rescue => e
        Rails.logger.error("Error enviando email de rechazo: #{e.message}")
      end
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

  # Todos los tickets pendientes del mismo comprador en este evento
  def same_buyer_pending(ticket)
    scope = @event.tickets.where(
      vendedor:    current_user,
      guest_email: ticket.guest_email,
      guest_name:  ticket.guest_name,
      status:      :reservado
    )
    scope.to_a
  end

  def send_acreditado_email(ticket)
    TicketMailer.ticket_acreditado(ticket.user, ticket).deliver_later
  end

  def send_rechazado_email(ticket)
    return if ticket.user.present?
    TicketMailer.ticket_rechazado_guest(ticket).deliver_later
  end
end
