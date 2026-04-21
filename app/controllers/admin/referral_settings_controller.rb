class Admin::ReferralSettingsController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard"

  def show
    @membership_config = ReferralRewardConfig.find_or_create_by!(reward_type: "membership") { |c| c.points = 200 }
    @ticket_config     = ReferralRewardConfig.find_or_create_by!(reward_type: "ticket")     { |c| c.points = 100 }
  end

  def update
    @membership_config = ReferralRewardConfig.find_or_create_by!(reward_type: "membership") { |c| c.points = 200 }
    @ticket_config     = ReferralRewardConfig.find_or_create_by!(reward_type: "ticket")     { |c| c.points = 100 }

    membership_points = params.dig(:referral_settings, :membership_points).to_i
    ticket_points     = params.dig(:referral_settings, :ticket_points).to_i

    ActiveRecord::Base.transaction do
      @membership_config.update!(points: membership_points)
      @ticket_config.update!(points: ticket_points)
    end

    redirect_to admin_referral_settings_path, notice: "Configuración de referidos actualizada correctamente."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error al guardar: #{e.message}"
    render :show, status: :unprocessable_entity
  end
end
