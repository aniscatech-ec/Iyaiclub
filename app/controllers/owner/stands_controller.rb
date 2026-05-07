class Owner::StandsController < Owner::BaseController
  def show
    @stand   = current_stand
    @events  = @stand.events.order(created_at: :desc)
    @vendors = EventVendedor.includes(:user, :event)
                            .where(stand: @stand)
                            .order(created_at: :desc)
  end
end
