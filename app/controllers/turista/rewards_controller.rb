class Turista::RewardsController < ApplicationController
  include MembershipAuthorization

  before_action :authenticate_turista!
  before_action :require_basic_membership!, only: [:redeem]
  layout "dashboard"

  def index
    @rewards = Reward.active.includes(:establishment)
    @rewards = @rewards.by_category(params[:category]) if params[:category].present?
    @total_points = current_user.total_points
  end

  def redeem
    @reward = Reward.active.find(params[:id])
    
    if current_user.total_points < @reward.points_required
      redirect_to turista_rewards_path, alert: "No tienes suficientes puntos para canjear esta recompensa"
      return
    end

    @redemption = current_user.redemptions.build(
      reward: @reward,
      points_used: @reward.points_required,
      status: :pendiente
    )

    if @redemption.save
      redirect_to turista_redemptions_path, notice: "Canje solicitado exitosamente"
    else
      redirect_to turista_rewards_path, alert: "Error al procesar el canje"
    end
  end
end
