class Turista::PointsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @total_points = current_user.total_points
    @points_history = current_user.user_points.includes(:establishment).recent
  end
end
