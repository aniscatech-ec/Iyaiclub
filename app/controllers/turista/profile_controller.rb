class Turista::ProfileController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def show
    @user           = current_user
    @total_points   = current_user.total_points
    @recent_points  = current_user.user_points.includes(:establishment).recent.limit(5)
    @active_membership = current_user.active_membership
    @bookings_count = current_user.bookings.where(status: "confirmado").count
    @pending_claims = current_user.invoice_claims.where(status: :pendiente).count
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to turista_profile_path, notice: "Perfil actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :phone, :birth_date, :marketing_consent)
  end
end
