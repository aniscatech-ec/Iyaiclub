class Vendedor::StandTicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_vendedor!
  before_action :set_event_and_stand
  before_action :set_ticket, only: [:acreditar, :rechazar]
  before_action :set_bulk_tickets, only: [:bulk_acreditar, :bulk_rechazar]
  layout "dashboard"

  def index
    @all_tickets = @event.tickets.where(vendedor: current_user, stand: @stand)
    @buyers      = @all_tickets.distinct.order(:guest_name).pluck(:guest_name).compact.reject(&:blank?)
    @codes       = @all_tickets.order(:ticket_code).pluck(:ticket_code).compact

    @tickets = @all_tickets.order(created_at: :desc)
    @tickets = @tickets.where(status: params[:status])    if params[:status].present?
    @tickets = @tickets.where(guest_name: params[:buyer]) if params[:buyer].present?
    @tickets = @tickets.where(ticket_code: params[:code]) if params[:code].present?
    @tickets = @tickets.to_a
  end

  def acreditar
    unless @ticket.reservado?
      redirect_to vendedor_event_stand_tickets_path(@event, @stand),
                  alert: "Este ticket no puede ser acreditado (estado: #{@ticket.status})."
      return
    end

    group = same_buyer_pending(@ticket)
    group.each(&:acreditar!)

    @event.event_vendedores.find_by(user: current_user, stand: @stand)&.check_and_mark_quota!

    begin
      TicketMailer.ticket_acreditado(group.first.user, group).deliver_now
    rescue => e
      Rails.logger.error("[TicketMailer] #{e.class} - #{e.message}")
    end

    msg = group.size > 1 ? "#{group.size} tickets de #{@ticket.guest_name.split('·').first.strip} acreditados." \
                         : "Ticket #{@ticket.ticket_code} acreditado."
    redirect_to vendedor_event_stand_tickets_path(@event, @stand), notice: msg
  end

  def rechazar
    unless @ticket.reservado?
      redirect_to vendedor_event_stand_tickets_path(@event, @stand),
                  alert: "Este ticket no puede ser rechazado (estado: #{@ticket.status})."
      return
    end

    group = same_buyer_pending(@ticket)
    group.each(&:rechazar!)

    begin
      TicketMailer.ticket_rechazado_guest(group.first).deliver_now
    rescue => e
      Rails.logger.error("[TicketMailer] #{e.class} - #{e.message}")
    end

    msg = group.size > 1 ? "#{group.size} tickets rechazados." : "Ticket #{@ticket.ticket_code} rechazado."
    redirect_to vendedor_event_stand_tickets_path(@event, @stand), notice: msg
  end

  def bulk_acreditar
    acreditados = 0
    @bulk_tickets.each do |ticket|
      next unless ticket.reservado?
      ticket.acreditar!
      acreditados += 1
    end

    @event.event_vendedores.find_by(user: current_user, stand: @stand)&.check_and_mark_quota!

    @bulk_tickets.reload.select(&:activo?).group_by { |t| t.guest_email.presence || t.guest_name }.each do |_, group|
      begin
        TicketMailer.ticket_acreditado(group.first.user, group).deliver_now
      rescue => e
        Rails.logger.error("[TicketMailer] #{e.class} - #{e.message}")
      end
    end

    redirect_to vendedor_event_stand_tickets_path(@event, @stand),
                notice: "#{acreditados} ticket#{'s' if acreditados != 1} acreditado#{'s' if acreditados != 1}."
  end

  def bulk_rechazar
    rechazados = 0
    @bulk_tickets.each do |ticket|
      next unless ticket.reservado?
      ticket.rechazar!
      begin
        TicketMailer.ticket_rechazado_guest(ticket).deliver_now
      rescue => e
        Rails.logger.error("[TicketMailer] #{e.class} - #{e.message}")
      end
      rechazados += 1
    end
    redirect_to vendedor_event_stand_tickets_path(@event, @stand),
                notice: "#{rechazados} ticket#{'s' if rechazados != 1} rechazado#{'s' if rechazados != 1}."
  end

  private

  def set_event_and_stand
    @event = Event.find(params[:event_id])
    @stand = Stand.find(params[:stand_id])

    # Verificar que el vendedor esté asignado a este stand en este evento
    unless @event.event_vendedores.exists?(user: current_user, stand: @stand)
      redirect_to vendedor_dashboard_index_path, alert: "No tienes acceso a este stand."
    end
  end

  def set_ticket
    @ticket = @event.tickets.where(vendedor: current_user, stand: @stand).find(params[:id])
  end

  def set_bulk_tickets
    ids = Array(params[:ticket_ids])
    if ids.blank?
      redirect_to vendedor_event_stand_tickets_path(@event, @stand), alert: "No seleccionaste ningún ticket."
      return
    end
    @bulk_tickets = @event.tickets.where(vendedor: current_user, stand: @stand, id: ids)
  end

  def same_buyer_pending(ticket)
    scope = @event.tickets.where(vendedor: current_user, stand: @stand, status: :reservado)
    scope = if ticket.guest_email.present?
              scope.where(guest_email: ticket.guest_email)
            else
              scope.where(guest_name: ticket.guest_name)
            end
    results = scope.to_a
    results << ticket unless results.map(&:id).include?(ticket.id)
    results
  end
end
