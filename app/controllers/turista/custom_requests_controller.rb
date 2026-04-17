class Turista::CustomRequestsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @custom_requests = current_user.custom_requests.recent
    @pagy, @custom_requests = pagy(@custom_requests, items: 10) if respond_to?(:pagy)
  end

  def show
    @custom_request = current_user.custom_requests.find(params[:id])
  end
end
