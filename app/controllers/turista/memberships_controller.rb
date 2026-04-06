class Turista::MembershipsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @active_membership = current_user.active_membership
    @available_plans = PlanPrice.where(target_role: :turista).includes(:plan)
  end
end
