class Vendedor::SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_vendedor!
  layout "dashboard"

  def index
    # --- Tickets vendidos (acreditados o activos, no cancelados ni reservados pendientes) ---
    ticket_sales = current_user.handled_tickets
                               .where(status: [ :activo, :usado ])
                               .includes(:event)
                               .order(created_at: :desc)

    # --- Membresías vendidas (activadas) ---
    membership_sales = current_user.handled_subscriptions
                                   .where(status: :activada)
                                   .includes(:subscribable)
                                   .order(created_at: :desc)

    # --- Historial unificado: convertir a objetos con interfaz común ---
    @sales = build_sales_list(ticket_sales, membership_sales)

    # --- Filtros ---
    if params[:month].present? && params[:year].present?
      month = params[:month].to_i
      year  = params[:year].to_i
      @sales = @sales.select do |s|
        s[:date].month == month && s[:date].year == year
      end
    end

    if params[:type].present?
      @sales = @sales.select { |s| s[:type] == params[:type] }
    end

    # --- Contadores por mes (últimos 12 meses) ---
    @monthly_counts = build_monthly_counts(ticket_sales, membership_sales)

    # --- Totales generales ---
    @total_tickets      = current_user.handled_tickets.where(status: [ :activo, :usado ]).count
    @total_memberships  = current_user.handled_subscriptions.where(status: :activada).count
    @total_revenue      = calculate_total_revenue(ticket_sales, membership_sales)
  end

  private

  def build_sales_list(tickets, memberships)
    list = []

    tickets.each do |ticket|
      list << {
        type:        "ticket",
        date:        ticket.created_at,
        client_name: ticket.guest_name.to_s.split("·").first.strip,
        client_email: ticket.guest_email,
        product:     ticket.event_name,
        detail:      "Ticket #{ticket.ticket_code}",
        amount:      ticket.total_price,
        status:      ticket.status,
        object:      ticket
      }
    end

    memberships.each do |sub|
      plan_price = PlanPrice.find_by(id: sub.plan_type)
      list << {
        type:        "membresia",
        date:        sub.created_at,
        client_name: sub.subscriber_name,
        client_email: sub.subscriber_email,
        product:     plan_price ? "#{plan_price.plan&.name} – #{plan_price.display_duration}" : "Membresía",
        detail:      "Membresía #{sub.id}",
        amount:      plan_price&.price || 0,
        status:      sub.status,
        object:      sub
      }
    end

    list.sort_by { |s| s[:date] }.reverse
  end

  def build_monthly_counts(tickets, memberships)
    counts = {}
    12.times do |i|
      date  = i.months.ago.beginning_of_month
      key   = date.strftime("%Y-%m")
      label = I18n.l(date, format: "%B %Y").capitalize

      t_count = tickets.count    { |t| t.created_at >= date && t.created_at < date.next_month }
      m_count = memberships.count { |m| m.created_at >= date && m.created_at < date.next_month }

      counts[key] = { label: label, tickets: t_count, memberships: m_count, total: t_count + m_count }
    end
    counts
  end

  def calculate_total_revenue(tickets, memberships)
    ticket_revenue     = tickets.sum { |t| t.total_price.to_f }
    membership_revenue = memberships.sum do |sub|
      PlanPrice.find_by(id: sub.plan_type)&.price.to_f
    end
    ticket_revenue + membership_revenue
  end
end
