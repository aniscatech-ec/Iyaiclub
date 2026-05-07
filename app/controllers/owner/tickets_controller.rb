class Owner::TicketsController < Owner::BaseController
  before_action :set_event
  before_action :set_ticket, only: [:acreditar, :rechazar]
  before_action :set_bulk_tickets, only: [:bulk_acreditar, :bulk_rechazar]

  def index
    @all_tickets = @event.tickets.where(stand: current_stand)
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
      redirect_to owner_stand_event_tickets_path(event_id: @event.id),
                  alert: "Este ticket no puede ser acreditado (estado: #{@ticket.status})."
      return
    end

    group = same_buyer_pending(@ticket)
    group.each(&:acreditar!)

    current_stand.event_vendedores.find_by(event: @event)&.check_and_mark_quota!
    process_ticket_referral(@ticket)

    begin
      send_acreditado_email(group)
    rescue => e
      Rails.logger.error("[TicketMailer] Error: #{e.message}")
    end

    msg = group.size > 1 ? "#{group.size} tickets de #{@ticket.guest_name.split('·').first.strip} acreditados." \
                         : "Ticket #{@ticket.ticket_code} acreditado."
    redirect_to owner_stand_event_tickets_path(event_id: @event.id), notice: msg
  end

  def rechazar
    unless @ticket.reservado?
      redirect_to owner_stand_event_tickets_path(event_id: @event.id),
                  alert: "Este ticket no puede ser rechazado (estado: #{@ticket.status})."
      return
    end

    group = same_buyer_pending(@ticket)
    group.each(&:rechazar!)

    begin
      send_rechazado_email(group.first)
    rescue => e
      Rails.logger.error("[TicketMailer] Error: #{e.message}")
    end

    msg = group.size > 1 ? "#{group.size} tickets rechazados." : "Ticket #{@ticket.ticket_code} rechazado."
    redirect_to owner_stand_event_tickets_path(event_id: @event.id), notice: msg
  end

  def bulk_acreditar
    acreditados = 0
    @bulk_tickets.each do |ticket|
      next unless ticket.reservado?
      ticket.acreditar!
      acreditados += 1
    end

    @bulk_tickets.reload.select(&:activo?).each { |t| process_ticket_referral(t) }
    current_stand.event_vendedores.find_by(event: @event)&.check_and_mark_quota!

    @bulk_tickets.reload.select(&:activo?).group_by { |t| t.guest_email.presence || t.guest_name }.each do |_, group|
      begin; send_acreditado_email(group); rescue => e; Rails.logger.error("[TicketMailer] #{e.message}"); end
    end

    redirect_to owner_stand_event_tickets_path(event_id: @event.id),
                notice: "#{acreditados} ticket(s) acreditado(s)."
  end

  def bulk_rechazar
    rechazados = 0
    @bulk_tickets.each do |ticket|
      next unless ticket.reservado?
      ticket.rechazar!
      begin; send_rechazado_email(ticket); rescue => e; Rails.logger.error("[TicketMailer] #{e.message}"); end
      rechazados += 1
    end
    redirect_to owner_stand_event_tickets_path(event_id: @event.id),
                notice: "#{rechazados} ticket(s) rechazado(s)."
  end

  private

  def set_event
    autonomo_type = EventVendedor.vendor_types[:stand_autonomo]
    allowed_ids = EventStand.where(stand_id: current_stand.id).pluck(:event_id) |
                  EventVendedor.where(stand_id: current_stand.id, vendor_type: autonomo_type).pluck(:event_id)
    @event = Event.find(params[:event_id])
    raise ActiveRecord::RecordNotFound unless allowed_ids.include?(@event.id)
  end

  def set_ticket
    @ticket = @event.tickets.where(stand: current_stand).find(params[:id])
  end

  def set_bulk_tickets
    ids = Array(params[:ticket_ids])
    if ids.blank?
      redirect_to owner_stand_event_tickets_path(event_id: @event.id), alert: "No seleccionaste ningún ticket."
      return
    end
    @bulk_tickets = @event.tickets.where(stand: current_stand, id: ids)
  end

  def same_buyer_pending(ticket)
    scope = @event.tickets.where(stand: current_stand, status: :reservado)
    scope = ticket.guest_email.present? ? scope.where(guest_email: ticket.guest_email) \
                                        : scope.where(guest_name: ticket.guest_name)
    results = scope.to_a
    results << ticket unless results.map(&:id).include?(ticket.id)
    results
  end

  def send_acreditado_email(tickets)
    TicketMailer.ticket_acreditado(Array(tickets).first.user, Array(tickets)).deliver_now
  end

  def send_rechazado_email(ticket)
    TicketMailer.ticket_rechazado_guest(ticket).deliver_now
  end

  def process_ticket_referral(ticket)
    return if ticket.referral_code.blank?
    Referral.process(
      referral_code:  ticket.referral_code,
      reward_type:    "ticket",
      referred_user:  ticket.user,
      referred_email: ticket.guest_email,
      source:         ticket
    )
  rescue => e
    Rails.logger.error("[Referral] #{e.message}")
  end
end
