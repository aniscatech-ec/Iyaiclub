class ReservationsController < ApplicationController
  before_action :set_unit

  # def index
  #   @unit = Unit.find(params[:unit_id])
  #   @reservations = @unit.reservations
  #
  #   respond_to do |format|
  #     format.html
  #     format.json do
  #       render json: @reservations.map { |r|
  #         {
  #           id: r.id,
  #           title: "Reservado",
  #           start: r.start_date,
  #           end: r.end_date + 1.day,
  #           color: "#dc3545"
  #         }
  #       }
  #     end
  #   end
  # end
  def index
    @hotel = Hotel.find(params[:hotel_id])
    @unit = @hotel.units.find(params[:unit_id])
    @reservations = @unit.reservations.includes(:user).order(start_date: :asc)
  end



  def new
    @hotel = Hotel.find(params[:hotel_id])
    @unit = @hotel.units.find(params[:unit_id])
    @reservation = @unit.reservations.new
    @reserved_ranges = @unit.reservations.map { |r| { start: r.start_date, end: r.end_date } }
  end


  def show
    @hotel = Hotel.find(params[:hotel_id])
    @unit = @hotel.units.find(params[:unit_id])
    @reservation = @unit.reservations.find(params[:id])

    # Todas las reservas de esa unidad para el calendario
    @reservations = @unit.reservations.includes(:user)
  end


  def edit
    @hotel = Hotel.find(params[:hotel_id])
    @unit = @hotel.units.find(params[:unit_id])
    @reservation = @unit.reservations.find(params[:id])

    # Excluye el rango actual de la reserva para permitir mover dentro de su propio rango
    @reserved_ranges = @unit.reservations
                            .where.not(id: @reservation.id)
                            .map { |r| { start: r.start_date, end: r.end_date } }
  end

  def update
    @reservation = Reservation.find(params[:id])
    @unit = @reservation.unit
    @hotel = @unit.hotel

    if @reservation.update(reservation_params)
      redirect_to [@hotel, @unit, @reservation], notice: "✅ Reserva actualizada correctamente."
    else
      # Volvemos a pasar los datos al formulario edit para que no falle el Stimulus controller
      @reserved_ranges = Reservation.where(unit_id: @unit.id)
                                    .where.not(id: @reservation.id)
                                    .pluck(:start_date, :end_date)
                                    .map { |s, e| { start: s, end: e } }

      flash.now[:alert] = "⚠️ No se pudo actualizar la reserva. Revisa los campos."
      render :edit, status: :unprocessable_entity
    end
  end


  def create
    @unit = Unit.find(params[:unit_id])
    @reservation = @unit.reservations.new(reservation_params)

    if @reservation.save
      redirect_to hotel_unit_path(@unit.hotel, @unit), notice: "Reserva creada correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def set_unit
    @unit = Unit.find(params[:unit_id])
  end

  def reservation_params
    params.require(:reservation).permit(:user_id, :start_date, :end_date, :status, :notes)
  end
end
