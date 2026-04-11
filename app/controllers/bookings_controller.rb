class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_hotel
  before_action :set_booking, only: [:show, :update]

  def index
    @bookings = if current_user.turista?
                  Booking.joins(:room).where(guest_email: current_user.email, rooms: { hotel_id: @hotel.id })
                elsif current_user.afiliado? || current_user.administrador?
                  Booking.joins(:room).where(rooms: { hotel_id: @hotel.id })
                else
                  Booking.none
                end
  end

  def new
    @room = @hotel.rooms.find(params[:room_id])
    @booking = @room.bookings.build(status: :pendiente)
  end

  def create
    @room = @hotel.rooms.find(booking_params[:room_id])
    @booking = @room.bookings.build(booking_params.except(:room_id))
    @booking.status = :pendiente

    if @booking.save
      redirect_to hotel_booking_path(@hotel, @booking), notice: "Reserva creada exitosamente. Pendiente de confirmación."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def update
    unless current_user.afiliado? || current_user.administrador?
      redirect_to hotel_booking_path(@hotel, @booking), alert: "No tienes permiso para esta acción" and return
    end

    if @booking.update(status: params[:booking][:status])
      redirect_to hotel_booking_path(@hotel, @booking), notice: "Estado de reserva actualizado a: #{@booking.status}"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_hotel
    @hotel = Hotel.includes(:rooms, :establishment).find(params[:hotel_id])
  end

  def set_booking
    @booking = Booking.joins(:room).where(rooms: { hotel_id: @hotel.id }).find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:room_id, :guest_name, :guest_email, :guest_count, :start_date, :end_date)
  end
end
