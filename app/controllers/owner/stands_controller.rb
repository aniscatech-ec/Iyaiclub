class Owner::StandsController < Owner::BaseController
  def show
    @stand  = current_stand
    autonomo_type = EventVendedor.vendor_types[:stand_autonomo]
    event_ids = EventStand.where(stand_id: @stand.id).pluck(:event_id) |
                EventVendedor.where(stand_id: @stand.id, vendor_type: autonomo_type).pluck(:event_id)
    @events = Event.where(id: event_ids).order(created_at: :desc)

    # EventVendedores autónomos del stand (uno por evento asignado)
    @stand_event_vendedores = EventVendedor.includes(:event)
                                           .where(stand: @stand, vendor_type: :stand_autonomo)
                                           .order(created_at: :desc)

    # Totales globales del stand
    @total_tickets_sold    = @stand_event_vendedores.sum(&:tickets_sold)
    @total_tickets_pending = @stand_event_vendedores.sum(&:tickets_pending)
  end
end
