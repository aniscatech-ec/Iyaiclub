class Admin::PlansController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    @plans = Plan.includes(:plan_prices).order(:sort_order, :name)
  end

  def show
    @plan_prices = @plan.plan_prices.order(:duration)
  end

  def new
    @plan = Plan.new
  end

  def create
    @plan = Plan.new(plan_params)

    if @plan.save
      redirect_to admin_plan_path(@plan), notice: "Plan creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @plan.update(plan_params)
      redirect_to admin_plan_path(@plan), notice: "Plan actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @plan.plan_prices.joins(:subscriptions).exists?
      redirect_to admin_plans_path, alert: "No se puede eliminar un plan con suscripciones activas."
    else
      @plan.destroy
      redirect_to admin_plans_path, notice: "Plan eliminado correctamente."
    end
  end

  private

  def set_plan
    @plan = Plan.find(params[:id])
  end

  def plan_params
    params.require(:plan).permit(
      :name,
      :description,
      :plan_key,
      :discount_percentage,
      :fixed_discount,
      :points_earned,
      :dollars_per_point,
      :pool_visits_per_year,
      :pool_level,
      :max_pool_guests,
      :free_nights,
      :free_days,
      :includes_breakfast,
      :includes_dinner,
      :max_lodging_guests,
      :events_access,
      :is_student_plan,
      :is_active,
      :sort_order,
      features: []
    )
  end
end
