class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_parent, except: [:index]
  before_action :set_booking, only: [:show, :update, :destroy]

  def index
    @bookings = if params[:hotel_id]
                  @hotel = Hotel.find(params[:hotel_id])
                  if current_user.turista?
                    Booking.joins("INNER JOIN units ON bookings.bookable_id = units.id AND bookings.bookable_type = 'Unit'")
                           .where(guest_email: current_user.email, units: { establishment_id: @hotel.establishment.id })
                  else
                    Booking.joins("INNER JOIN units ON bookings.bookable_id = units.id AND bookings.bookable_type = 'Unit'")
                           .where(units: { establishment_id: @hotel.establishment.id })
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
      @unit = @hotel.establishment.units.find(params[:unit_id])
      @booking = @unit.bookings.build(status: :pendiente)
    else
      @booking = @parent.bookings.build(status: :pendiente)
    end
  end

  def create
    if @hotel
      @unit = @hotel.establishment.units.find(booking_params[:unit_id])
      @booking = @unit.bookings.build(booking_params.except(:unit_id, :date, :guests))
    else
      @booking = @parent.bookings.build(booking_params.except(:unit_id))
    end

    @booking.user = current_user
    @booking.status = :pendiente

    # Calcular precio total
    @booking.total_price = calculate_booking_price(@booking)

    if @booking.save
      establishment = @booking.bookable&.establishment

      # Si IyaiClub gestiona la reserva → cobrar por PayPhone
      if establishment&.iyaiclub?
        redirect_to payphone_checkout_path(
          payable_type: "Booking",
          payable_id: @booking.id
        ), notice: "Reserva creada. Completa el pago para confirmarla."
      else
        # Autogestion: reserva queda pendiente, el afiliado la confirma
        redirect_path = @hotel ? hotel_booking_path(@hotel, @booking) : polymorphic_path([@parent, @booking])
        redirect_to redirect_path, notice: "Reserva creada. Pendiente de confirmación por el establecimiento."
      end
    else
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
                 Booking.joins("INNER JOIN units ON bookings.bookable_id = units.id AND bookings.bookable_type = 'Unit'")
                        .where(units: { establishment_id: @hotel.establishment.id })
                        .find(params[:id])
               elsif @parent
                 @parent.bookings.find(params[:id])
               else
                 Booking.find(params[:id])
               end
  end

  def booking_params
    params.require(:booking).permit(
      :unit_id, :guest_name, :guest_email, :guest_count, :start_date, :end_date, :status,
      :date, :guests # aliases
    )
  end

  def calculate_booking_price(booking)
    return 0 if booking.start_date.blank? || booking.end_date.blank?
    nights = (booking.end_date - booking.start_date).to_i
    return 0 if nights <= 0

    bookable = booking.bookable
    price_per_night = case bookable
                      when Unit then bookable.base_price
                      when Lodging then bookable.price_per_night
                      else 0
                      end

    nights * (price_per_night || 0)
  end
end
