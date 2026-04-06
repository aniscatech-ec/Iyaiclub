class Turista::DashboardController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @total_points = current_user.total_points
    @active_membership = current_user.active_membership
    @recent_bookings = current_user.bookings.includes(unit: :establishment).order(created_at: :desc).limit(2)
    @recent_visits = current_user.visits.includes(:establishment).recent.limit(4)
    @bookings_count = current_user.bookings.count
    @visits_count = current_user.visits.count
  end
end
