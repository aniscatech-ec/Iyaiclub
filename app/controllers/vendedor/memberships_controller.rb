class Vendedor::MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_vendedor!
  before_action :set_membership, only: [:acreditar, :rechazar, :suspender, :reactivar, :destroy]
  before_action :set_bulk_memberships, only: [:bulk_acreditar, :bulk_rechazar]
  layout "dashboard"

  def index
    @all_memberships = Subscription.where(vendedor: current_user)
    @subscribers     = @all_memberships.includes(:subscribable).map(&:subscribable).compact
                                       .uniq.map(&:name).compact.reject(&:blank?).sort
    # @plans: array de [nombre_display, plan_price_id] para el select
    @plans = @all_memberships.map(&:plan_type).compact.uniq.filter_map do |pt_id|
      pp = PlanPrice.find_by(id: pt_id)
      pp ? ["#{pp.plan_type&.humanize} – #{pp.display_duration}", pp.id.to_s] : nil
    end.uniq.sort_by(&:first)

    @memberships = @all_memberships.includes(:subscribable).order(created_at: :desc)
    @memberships = @memberships.where(status: params[:status])           if params[:status].present?
    @memberships = @memberships.joins("INNER JOIN users ON users.id = subscriptions.subscribable_id AND subscriptions.subscribable_type = 'User'")
                               .where("users.name = ?", params[:subscriber]) if params[:subscriber].present?
    @memberships = @memberships.where(plan_type: params[:plan])          if params[:plan].present?
  end

  def acreditar
    if @membership.reservada?
      @membership.acreditar!
      process_membership_referral(@membership)
      begin
        UserMailer.membership_notification(@membership.subscribable, :activada, @membership).deliver_later
      rescue => e
        Rails.logger.error("Error enviando email de membresía acreditada: #{e.message}")
      end
      redirect_to vendedor_memberships_path,
                  notice: "Membresía de #{@membership.subscriber_name} acreditada correctamente."
    else
      redirect_to vendedor_memberships_path,
                  alert: "Esta membresía no puede ser acreditada (estado: #{@membership.status})."
    end
  end

  def rechazar
    if @membership.reservada?
      @membership.rechazar!
      redirect_to vendedor_memberships_path,
                  notice: "Membresía de #{@membership.subscriber_name} rechazada."
    else
      redirect_to vendedor_memberships_path,
                  alert: "Esta membresía no puede ser rechazada (estado: #{@membership.status})."
    end
  end

  def suspender
    if @membership.activada?
      @membership.suspender!
      redirect_to vendedor_memberships_path,
                  notice: "Membresía de #{@membership.subscriber_name} suspendida. Los beneficios han sido desactivados."
    else
      redirect_to vendedor_memberships_path,
                  alert: "Solo se pueden suspender membresías activas."
    end
  end

  def reactivar
    if @membership.suspendida?
      @membership.reactivar!
      redirect_to vendedor_memberships_path,
                  notice: "Membresía de #{@membership.subscriber_name} reactivada correctamente."
    else
      redirect_to vendedor_memberships_path,
                  alert: "Solo se pueden reactivar membresías suspendidas."
    end
  end

  def destroy
    nombre = @membership.subscriber_name
    @membership.destroy!
    redirect_to vendedor_memberships_path,
                notice: "Membresía de #{nombre} eliminada permanentemente."
  end

  def bulk_acreditar
    acreditadas = 0
    @bulk_memberships.each do |membership|
      next unless membership.reservada?
      membership.acreditar!
      process_membership_referral(membership)
      begin
        UserMailer.membership_notification(membership.subscribable, :activada, membership).deliver_later
      rescue => e
        Rails.logger.error("Error enviando email membresía acreditada: #{e.message}")
      end
      acreditadas += 1
    end
    redirect_to vendedor_memberships_path,
                notice: "#{acreditadas} #{'membresía'.pluralize(acreditadas)} acreditada#{'s' if acreditadas != 1} correctamente."
  end

  def bulk_rechazar
    rechazadas = 0
    @bulk_memberships.each do |membership|
      next unless membership.reservada?
      membership.rechazar!
      rechazadas += 1
    end
    redirect_to vendedor_memberships_path,
                notice: "#{rechazadas} #{'membresía'.pluralize(rechazadas)} rechazada#{'s' if rechazadas != 1}."
  end

  private

  def set_membership
    @membership = Subscription.where(vendedor: current_user).find(params[:id])
  end

  def set_bulk_memberships
    ids = Array(params[:membership_ids])
    if ids.blank?
      redirect_to vendedor_memberships_path, alert: "No seleccionaste ninguna membresía."
      return
    end
    @bulk_memberships = Subscription.where(vendedor: current_user, id: ids)
  end

  def process_membership_referral(membership)
    return if membership.referral_code.blank?
    referred_user = membership.subscribable.is_a?(User) ? membership.subscribable : nil
    Referral.process(
      referral_code:  membership.referral_code,
      reward_type:    "membership",
      referred_user:  referred_user,
      referred_email: referred_user&.email,
      source:         membership
    )
  rescue => e
    Rails.logger.error("[Referral] Error en membership referral: #{e.message}")
  end
end
