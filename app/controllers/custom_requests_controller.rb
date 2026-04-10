class CustomRequestsController < ApplicationController
  before_action :authenticate_user!

  def new
    @custom_request = CustomRequest.new
  end

  def create
    @custom_request = current_user.custom_requests.new(custom_request_params)

    if @custom_request.save
      redirect_to redirect_target_after_create,
                  notice: "Tu solicitud fue enviada. Nuestro equipo Iyaiclub se pondrá en contacto contigo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def custom_request_params
    params.require(:custom_request).permit(
      :destination, :start_date, :end_date, :guests_count,
      :estimated_budget, :experience_type, :comments,
      interests: [], preferences: []
    )
  end

  def redirect_target_after_create
    case current_user.role
    when "turista"       then turista_custom_request_path(@custom_request)
    when "administrador" then admin_custom_request_path(@custom_request)
    else root_path
    end
  end
end
