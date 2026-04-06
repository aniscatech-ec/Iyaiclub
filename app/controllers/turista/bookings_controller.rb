class Turista::BookingsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @bookings = current_user.bookings.includes(unit: :establishment).order(created_at: :desc)
  end

  def show
    @booking = current_user.bookings.includes(unit: :establishment).find(params[:id])
  end
end
