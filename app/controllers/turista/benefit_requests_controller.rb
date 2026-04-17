class Turista::BenefitRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_turista!
  before_action :set_bookable
  layout "dashboard"

  def new
    unless benefit_allowed?
      redirect_to turista_memberships_path,
                  alert: "No tienes beneficios disponibles para este tipo de solicitud con tu plan actual."
      return
    end

    @booking = Booking.new(
      bookable:        @bookable,
      user:            current_user,
      guest_name:      current_user.name,
      guest_email:     current_user.email,
      benefit_request: true,
      benefit_type:    params[:benefit_type],
      total_price:     0
    )
  end

  def create
    unless benefit_allowed?
      redirect_to turista_memberships_path,
                  alert: "No tienes beneficios disponibles para este tipo de solicitud."
      return
    end

    @booking = Booking.new(benefit_params.merge(bookable: @bookable))
    @booking.user            = current_user
    @booking.status          = :pendiente
    @booking.benefit_request = true
    @booking.total_price     = 0

    if @booking.save
      UserMailer.benefit_request_confirmation(current_user, @booking).deliver_later
      UserMailer.benefit_request_admin_notification(current_user, @booking).deliver_later
      redirect_to turista_bookings_path,
                  notice: "¡Solicitud enviada! Nos pondremos en contacto contigo pronto para coordinar tu #{@booking.benefit_label}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_bookable
    @bookable = if params[:getaway_id]
                  Getaway.find(params[:getaway_id])
                elsif params[:hotel_id]
                  Hotel.find(params[:hotel_id])
                elsif params[:lodging_id]
                  Lodging.find(params[:lodging_id])
                else
                  raise ActiveRecord::RecordNotFound
                end
  end

  def benefit_allowed?
    type = benefit_type_param
    case type
    when "lodging" then current_user.can_request_lodging_benefit?
    when "pool"    then current_user.can_request_pool_benefit?
    else false
    end
  end

  # Obtiene benefit_type tanto del param de URL (GET) como del body del form (POST)
  def benefit_type_param
    params[:benefit_type].presence ||
      params.dig(:booking, :benefit_type).presence
  end

  def benefit_params
    params.require(:booking).permit(
      :benefit_type, :benefit_notes, :guest_name, :guest_email,
      :guest_count, :start_date, :end_date
    )
  end
end
