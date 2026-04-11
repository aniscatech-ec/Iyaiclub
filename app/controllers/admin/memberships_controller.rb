class Admin::MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_membership, only: [:show, :update, :destroy, :approve, :cancel]
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
    @plan_price = PlanPrice.find_by(id: @membership.plan_type)
  end

  def update
    if @membership.update(membership_params)
      redirect_to admin_membership_path(@membership), notice: "Membresía actualizada correctamente."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update_plan_price
    @plan_price = PlanPrice.find_by(id: @membership.plan_type)
    
    if @plan_price.update(plan_price_params)
      redirect_to admin_membership_path(@membership), notice: "Precio del plan actualizado correctamente."
    else
      redirect_to admin_membership_path(@membership), alert: "Error al actualizar el precio del plan."
    end
  end

  def destroy
    @membership.destroy
    redirect_to admin_memberships_path, notice: "Membresía eliminada correctamente."
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
end
