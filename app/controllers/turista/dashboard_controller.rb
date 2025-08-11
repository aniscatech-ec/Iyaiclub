class Turista::DashboardController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
  end
end
