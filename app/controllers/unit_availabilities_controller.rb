class UnitAvailabilitiesController < ApplicationController
  def index
    @unit = Unit.find(params[:unit_id])
    @unit_availabilities = @unit.unit_availabilities

    respond_to do |format|
      format.html
      format.json do
        render json: @unit_availabilities.map { |a|
          {
            id: a.id,
            title: (a.available ? "Disponible" : "Ocupado"),
            start: a.date,
            allDay: true,
            color: (a.available ? "#28a745" : "#dc3545")
          }
        }
      end
    end
  end

  def show
  end

  def new
    @unit = Unit.find(params[:unit_id])
    @unit_availability = UnitAvailability.new
  end

  # def create
  #   @unit = Unit.find(params[:unit_id])
  #   @unit_availability = @unit.unit_availabilities.create(unit_availability_params)
  #   redirect_to hotel_unit_path(@unit.hotel, @unit)
  # end

  def create
    @unit = Unit.find(params[:unit_id])
    date = params[:unit_availability][:date]

    # Busca o crea la disponibilidad para esa fecha
    @availability = @unit.unit_availabilities.find_or_initialize_by(date: date)

    if @availability.new_record?
      # Si no existía, marcamos como NO disponible (reservado)
      @availability.available = false
    else
      # Si ya existía, alternamos (por si se quiere liberar la fecha)
      @availability.available = !@availability.available
    end


    if @availability.save
      head :ok
    else
      render json: { error: @availability.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def toggle
    @unit_availability = UnitAvailability.find_or_initialize_by(
      unit_id: params[:unit_id],
      date: params[:date]
    )

    if @unit_availability.new_record?
      @unit_availability.available = false
    else
      @unit_availability.available = !@unit_availability.available
    end

    @unit_availability.save!
    render json: @unit_availability
  end


  def edit
  end

  private
  def unit_availability_params
    params.require(:unit_availability).permit(:date, :available)
  end

end
