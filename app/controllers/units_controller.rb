class UnitsController < ApplicationController
  def new
    @hotel = Hotel.find(params[:hotel_id])
    @unit = Unit.new
  end

  def show
    @unit = Unit.find(params[:id])
  end
  def create
    @hotel = Hotel.find(params[:hotel_id])
    @unit = @hotel.units.create(unit_params)
    redirect_to hotel_path(@hotel)
  end
    def edit
      @hotel = Hotel.find(params[:hotel_id])
      @unit = Unit.find(params[:id])
    end

    def update
      @unit = Unit.find(params[:id])

      if @unit.update(unit_params)
        redirect_to hotel_path(@unit.hotel)
      else
        render :edit, status: :unprocessable_entity
      end
    end


  private
  def unit_params
    params.require(:unit).permit(:unit_type, :capacity, :base_price, :bed_configuration)
  end
end
