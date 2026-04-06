class Turista::VisitsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @visits = current_user.visits.includes(:establishment).recent
  end
end
