class Admin::MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_membership, only: [:show, :update, :destroy, :approve, :cancel]
  before_action :set_benefit_booking, only: [:activate_benefit, :reject_benefit]
  layout "dashboard"

  def index
    @memberships = Subscription.joins("INNER JOIN users ON subscriptions.subscribable_id = users.id AND subscriptions.subscribable_type = 'User'")
                               .includes(:subscribable)
                               .order(created_at: :desc)

    @memberships = @memberships.where(status: params[:status]) if params[:status].present?

    @memberships = @memberships.page(params[:page]).per(20) if @memberships.respond_to?(:page)
  end

  def show
    @user = @membership.subscribable
    @plan_price = PlanPrice.find(@membership.plan_type)
  rescue ActiveRecord::RecordNotFound
    @plan_price = nil
  end

  def update
    if @membership.update(membership_params)
      redirect_to admin_membership_path(@membership), notice: "Membresía actualizada correctamente."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update_plan_price
    @plan_price = PlanPrice.find(@membership.plan_type)
    
    if @plan_price.update(plan_price_params)
      redirect_to admin_membership_path(@membership), notice: "Precio del plan actualizado correctamente."
    else
      redirect_to admin_membership_path(@membership), alert: "Error al actualizar el precio del plan."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_membership_path(@membership), alert: "Plan de precios no encontrado."
  end

  def destroy
    begin
      @membership.destroy
      redirect_to admin_memberships_path, notice: "Membresía eliminada correctamente."
    rescue ActiveRecord::DeleteRestrictionError => e
      redirect_to admin_membership_path(@membership), alert: "No se puede eliminar la membresía: #{e.message}"
    rescue StandardError => e
      redirect_to admin_membership_path(@membership), alert: "Error al eliminar la membresía: #{e.message}"
    end
  end

  def approve
    @membership.set_dates
    @membership.status = :activada

    if @membership.save
      redirect_to admin_memberships_path, notice: "Membresía aprobada correctamente."
    else
      redirect_to admin_memberships_path, alert: "Error al aprobar la membresía."
    end
  end

  def cancel
    if @membership.update(status: :cancelada)
      redirect_to admin_memberships_path, notice: "Membresía cancelada correctamente."
    else
      redirect_to admin_memberships_path, alert: "Error al cancelar la membresía."
    end
  end

  def benefit_requests
    @benefit_bookings = Booking.benefit_requests
                               .includes(:user, :bookable)
                               .order(created_at: :desc)
    @benefit_bookings = @benefit_bookings.where(status: params[:status]) if params[:status].present?
    @benefit_bookings = @benefit_bookings.where(benefit_type: params[:benefit_type]) if params[:benefit_type].present?
  end

  def activate_benefit
    @benefit_booking.activar_beneficio!
    UserMailer.benefit_activated(@benefit_booking.user, @benefit_booking).deliver_later
    redirect_to benefit_requests_admin_memberships_path,
                notice: "Beneficio activado. Se notificó al usuario #{@benefit_booking.user&.name}."
  end

  def reject_benefit
    @benefit_booking.update!(status: :rechazado, admin_notes: params[:admin_notes])
    redirect_to benefit_requests_admin_memberships_path,
                notice: "Solicitud rechazada."
  end

  private

  def set_membership
    @membership = Subscription.find(params[:id])
  end

  def membership_params
    params.require(:subscription).permit(:status, :end_date, :payment_method)
  end

  def plan_price_params
    params.require(:plan_price).permit(:price)
  end

  def set_benefit_booking
    @benefit_booking = Booking.benefit_requests.find(params[:id])
  end
end
