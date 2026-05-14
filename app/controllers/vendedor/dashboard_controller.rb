class Vendedor::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_vendedor!
  layout "dashboard"

  def index
    # Todos los slots de venta del vendedor (normal + stand)
    @event_vendedores = EventVendedor
                          .includes(:event, :stand)
                          .where(user: current_user)
                          .joins(:event)
                          .where(events: { status: :publicado })
                          .order("events.event_date ASC")

    # Eventos directos (sin stand asociado)
    @events_direct = @event_vendedores.where(vendor_type: :normal).map(&:event).uniq

    # Slots con stand (un vendedor puede estar en múltiples stands/eventos)
    @stand_slots = @event_vendedores.where(vendor_type: :stand)

    # Stands únicos asignados al vendedor
    @stands = @stand_slots.map(&:stand).compact.uniq

    @pending_count = Ticket.reservados.where(vendedor: current_user).count
    @pending_memberships_count = Subscription.where(vendedor: current_user, status: :reservada).count
    @memberships = Subscription.where(vendedor: current_user).includes(:subscribable)

    # Total de eventos (directos + por stand)
    @total_events_count = @event_vendedores.map(&:event_id).uniq.count
  end
end
