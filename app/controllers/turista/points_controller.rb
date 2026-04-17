class Turista::PointsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @total_points    = current_user.total_points
    @points_earned   = current_user.user_points.sum(:points_earned)
    @points_redeemed = current_user.redemptions.where(status: :aprobado).sum(:points_used)
    @points_history  = current_user.user_points.includes(:establishment).recent
    @redemptions     = current_user.redemptions.includes(:reward).recent
  end
end
