class Vendedor::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_vendedor!
  layout "dashboard"

  def index
    @events = current_user.vendedor_events
                          .where(status: :publicado)
                          .order(event_date: :asc)
    @pending_count = Ticket.reservados
                           .where(vendedor: current_user)
                           .count
  end
end
