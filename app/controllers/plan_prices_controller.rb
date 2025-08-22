class PlanPricesController < ApplicationController
  before_action :set_plan_price, only: %i[show edit update destroy]
  layout "dashboard"

  def index
    # @plan_prices = PlanPrice.all.order(:plan_type, :duration)
    @plan_prices = PlanPrice.all
  end

  def new
    @plan_price = PlanPrice.new
  end

  def show
    # @plan_price = PlanPrice.find(params[:id])
  end

  # def create
  #   @plan_price = PlanPrice.new(plan_price_params)
  #   if @plan_price.save
  #     redirect_to plan_prices_path, notice: "Precio guardado correctamente."
  #   else
  #     render :new
  #   end
  # end

  def create
    @plan_price = PlanPrice.new(plan_price_params)
    if @plan_price.save
      redirect_to plan_prices_path, notice: "Precio guardado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @plan_price.update(plan_price_params)
      redirect_to plan_prices_path, notice: "Precio actualizado correctamente."
    else
      render :edit
    end
  end

  def destroy
    @plan_price.destroy
    redirect_to plan_prices_path, notice: "Precio eliminado."
  end

  private

  def set_plan_price
    @plan_price = PlanPrice.find(params[:id])
  end

  def plan_price_params
    # params.require(:plan_price).permit(:target_role, :plan_type, :duration, :price)
    raw_params = params.require(:plan_price).permit(:target_role, :plan_type, :duration, :price, :features)

    if raw_params[:features].is_a?(String)
      raw_params[:features] = raw_params[:features].split("\n").map(&:strip).reject(&:blank?)
    end

    raw_params
  end
end
