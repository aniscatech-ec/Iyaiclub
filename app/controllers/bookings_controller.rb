class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_parent, except: [:index]
  before_action :set_booking, only: [:show, :update, :destroy]
  layout "dashboard"

  def index
    @bookings = if params[:hotel_id]
                  @hotel = Hotel.find(params[:hotel_id])
                  if current_user.turista?
                    Booking.joins("INNER JOIN rooms ON bookings.bookable_id = rooms.id AND bookings.bookable_type = 'Room'")
                           .where(guest_email: current_user.email, rooms: { hotel_id: @hotel.id })
                  else
                    Booking.joins("INNER JOIN rooms ON bookings.bookable_id = rooms.id AND bookings.bookable_type = 'Room'")
                           .where(rooms: { hotel_id: @hotel.id })
                  end
                elsif params[:experience_id]
                  @parent = Experience.find(params[:experience_id])
                  @parent.bookings
                elsif params[:lodging_id]
                  @parent = Lodging.find(params[:lodging_id])
                  @parent.bookings
                elsif params[:getaway_id]
                  @parent = Getaway.find(params[:getaway_id])
                  @parent.bookings
                else
                  current_user.bookings
                end

    respond_to do |format|
      format.html
      format.json { render json: @bookings }
    end
  end

  def new
    if @hotel
      @room = @hotel.rooms.find(params[:room_id])
      @booking = @room.bookings.build(status: :pendiente)
    else
      @booking = @parent.bookings.build(status: :pendiente)
    end
  end

  def create
    if @hotel
      @room = @hotel.rooms.find(booking_params[:room_id])
      @booking = @room.bookings.build(booking_params.except(:room_id, :date, :guests))
    else
      @booking = @parent.bookings.build(booking_params.except(:room_id))
    end

    @booking.user = current_user
    @booking.status = :pendiente

    # Calcular precio total
    @booking.total_price = calculate_booking_price(@booking)

    if @booking.save
      establishment = @booking.establishment
      show_path = @hotel ? hotel_booking_path(@hotel, @booking) : polymorphic_path([@parent, @booking])

      if establishment&.iyaiclub?
        redirect_to show_path, notice: "Reserva creada. Completa el pago con PayPhone para confirmarla."
      else
        redirect_to show_path, notice: "Reserva creada. Pendiente de confirmación por el establecimiento."
      end
    else
      @room ||= @hotel&.rooms&.find_by(id: booking_params[:room_id])
      render :new, status: :unprocessable_entity
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @booking }
    end
  end

  def update
    unless current_user.afiliado? || current_user.administrador?
      redirect_path = @hotel ? hotel_booking_path(@hotel, @booking) : (@parent ? polymorphic_path([@parent, @booking]) : bookings_path)
      redirect_to redirect_path, alert: "No tienes permiso para esta acción" and return

    end

    respond_to do |format|
      if @booking.update(status: params[:booking][:status])
        format.html do
          redirect_path = @hotel ? hotel_booking_path(@hotel, @booking) : polymorphic_path([@parent, @booking])
          redirect_to redirect_path, notice: "Estado de reserva actualizado a: #{@booking.status}"
        end
        format.json { render json: @booking }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @booking.destroy
    respond_to do |format|
      format.html do
        redirect_path = @hotel ? hotel_bookings_path(@hotel) : bookings_path
        redirect_to redirect_path, notice: 'Reserva cancelada exitosamente.'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_parent
    if params[:hotel_id]
      @hotel = Hotel.includes(establishment: [:units, :user]).find(params[:hotel_id])
      @parent = @hotel
    elsif params[:experience_id]
      @parent = Experience.find(params[:experience_id])
    elsif params[:lodging_id]
      @parent = Lodging.find(params[:lodging_id])
    elsif params[:getaway_id]
      @parent = Getaway.find(params[:getaway_id])
    end
  end

  def set_booking
    @booking = if @hotel
                 Booking.joins("INNER JOIN rooms ON bookings.bookable_id = rooms.id AND bookings.bookable_type = 'Room'")
                        .where(rooms: { hotel_id: @hotel.id })
                        .find(params[:id])
               elsif @parent
                 @parent.bookings.find(params[:id])
               else
                 Booking.find(params[:id])
               end
  end

  def booking_params
    params.require(:booking).permit(
      :room_id, :unit_id, :guest_name, :guest_email, :guest_count, :start_date, :end_date, :status,
      :date, :guests
    )
  end

  def calculate_booking_price(booking)
    bookable = booking.bookable
    return 0 unless bookable

    case bookable
    when Room
      return 0 if booking.start_date.blank? || booking.end_date.blank?
      nights = (booking.end_date - booking.start_date).to_i
      nights > 0 ? nights * (bookable.price_per_night || 0) : 0
    when Unit
      return 0 if booking.start_date.blank? || booking.end_date.blank?
      nights = (booking.end_date - booking.start_date).to_i
      nights > 0 ? nights * (bookable.base_price || 0) : 0
    when Lodging
      return 0 if booking.start_date.blank? || booking.end_date.blank?
      nights = (booking.end_date - booking.start_date).to_i
      nights > 0 ? nights * (bookable.price_per_night || 0) : 0
    when Experience
      # Precio por persona × número de personas
      (bookable.price || 0) * (booking.guest_count || 1)
    when Getaway
      # Precio de entrada × número de personas
      (bookable.entry_price || 0) * (booking.guest_count || 1)
    else
      0
    end
  end
end
