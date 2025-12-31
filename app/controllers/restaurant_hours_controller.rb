class RestaurantHoursController < ApplicationController
  before_action :set_restaurant
  before_action :set_restaurant_hour, only: [:edit, :update]
  def index
    @restaurant_hours = @restaurant.restaurant_hours.order(:day_of_week)
  end
  def new
    @restaurant_hour = @restaurant.restaurant_hours.build
  end

  def create
    @restaurant_hour = @restaurant.restaurant_hours.build(restaurant_hour_params)

    if @restaurant_hour.save
      redirect_to restaurant_path(@restaurant), notice: 'Horario creado correctamente'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @restaurant_hour.update(restaurant_hour_params)
      redirect_to restaurant_path(@restaurant), notice: 'Horario actualizado'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_restaurant_hour
    @restaurant_hour = @restaurant.restaurant_hours.find(params[:id])
  end

  def restaurant_hour_params
    params.require(:restaurant_hour).permit(
      :day_of_week,
      :open_time,
      :close_time,
      :closed
    )
  end
end
