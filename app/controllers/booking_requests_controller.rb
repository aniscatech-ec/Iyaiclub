class BookingRequestsController < ApplicationController
  def index
    @booking_requests = BookingRequest
                          .order(created_at: :desc)
  end

  def create
    booking = BookingRequest.create!(
      establishment_id: params[:establishment_id],
      user: current_user,
      source: params[:source],
      status: "pending",
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    head :ok
  end

end
