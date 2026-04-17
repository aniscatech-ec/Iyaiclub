class Turista::BookingsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @bookings = current_user.bookings.includes(bookable: :establishment).order(created_at: :desc)
  end

  def show
    @booking = current_user.bookings.includes(bookable: :establishment).find(params[:id])
  end
end
