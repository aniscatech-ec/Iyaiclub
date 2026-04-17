class Turista::MembershipsController < ApplicationController
  before_action :authenticate_turista!
  before_action :set_membership, only: [:cancel, :reactivate]
  layout "dashboard"

  def index
    @active_membership = current_user.active_membership
    @available_plans = PlanPrice.where(target_role: :turista).includes(:plan)
  end

  # POST /turista/memberships/:id/cancel
  # El usuario cancela voluntariamente. Los beneficios se mantienen hasta end_date.
  def cancel
    if @membership.activada?
      @membership.cancel_by_user!
      UserMailer.membership_notification(current_user, :cancelada, @membership).deliver_later
      redirect_to turista_memberships_path,
        notice: "Tu membresía ha sido cancelada. Seguirás disfrutando de tus beneficios hasta el #{@membership.end_date.strftime('%d/%m/%Y')}."
    else
      redirect_to turista_memberships_path, alert: "No tienes una membresía activa para cancelar."
    end
  end

  # DELETE /turista/memberships/:id/reactivate
  # El usuario deshace la cancelación voluntaria (solo si end_date no ha pasado)
  def reactivate
    if @membership.pending_cancellation?
      @membership.update!(cancelled_at: nil, cancellation_type: :por_usuario)
      redirect_to turista_memberships_path, notice: "Tu membresía ha sido reactivada correctamente."
    else
      redirect_to turista_memberships_path, alert: "No es posible reactivar esta membresía."
    end
  end

  private

  def set_membership
    @membership = current_user.subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to turista_memberships_path, alert: "Membresía no encontrada."
  end
end
