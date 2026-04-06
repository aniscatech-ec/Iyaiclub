class Turista::RedemptionsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @redemptions = current_user.redemptions.includes(:reward).recent
  end
end
