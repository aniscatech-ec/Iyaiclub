class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[show edit update destroy approve cancel]
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: %i[selector]

  layout "dashboard"

  # Afiliado ve las suyas, Admin ve todas
  def index
    if current_user.administrador?
      @subscriptions = Subscription.all
    else
      # @subscriptions = current_user.subscriptions
      # @subscriptions = Subscription.joins(:establishment).where(establishments: { user_id: current_user.id })

    end
  end

  def index_establishments
    if current_user.administrador?
    else
      # @subscriptions = current_user.subscriptions
      @establishments = current_user.establishments

    end
  end

  def establishment_plans
    if current_user.administrador?
    else
      # @subscriptions = current_user.subscriptions
      @establishment = Establishment.find(params[:id])
      @plans = PlanPrice.where(target_role: current_user.role)

    end
  end

  def tourist_plans
    if current_user.administrador?
    else
      # @subscriptions = current_user.subscriptions
      @user = current_user
      @plans = PlanPrice.where(target_role: current_user.role)
    end
  end

  def show
  end

  def edit
  end

  def new
    @subscription = Subscription.new
    @plan_price   = PlanPrice.find(params[:plan_id])

    # Vendedores asignados a este plan (activos), para el selector de transferencia
    plan = @plan_price.plan
    @plan_vendedores = plan ? plan.plan_vendedores.where(active: true).includes(:vendedor).map(&:vendedor) : []

    if current_user.administrador?
      @establishments = Establishment.all
    elsif current_user.afiliado?
      @establishment = current_user.establishments.find(params[:establishment_id])
    end
  end

  def create
    # El flujo de pago va directo al checkout de PayPhone desde el formulario new.
    # Este action no se usa normalmente, pero redirige como fallback.
    redirect_back fallback_location: root_path, alert: "Usa el botón de pago para completar tu suscripción."
  end

  # POST /subscriptions/reservar_transferencia
  # Crea una suscripción en estado :reservada asignada al vendedor elegido.
  def reservar_transferencia
    plan_price = PlanPrice.find(params[:plan_id])
    vendedor   = User.find_by(id: params[:vendedor_id], role: :vendedor)

    unless vendedor
      redirect_back fallback_location: turista_memberships_path,
                    alert: "Por favor selecciona un vendedor."
      return
    end

    subscribable_type = params[:subscribable_type].presence || "User"
    subscribable_id   = params[:subscribable_id].presence&.to_i || current_user.id

    subscription = Subscription.new(
      subscribable_type: subscribable_type,
      subscribable_id:   subscribable_id,
      plan_type:         plan_price.id,
      payment_method:    :transferencia,
      status:            :reservada,
      vendedor:          vendedor,
      reserved_at:       Time.current,
      referral_code:     params[:referral_code].to_s.strip.upcase.presence
    )

    if subscription.save
      redirect_to turista_memberships_path,
                  notice: "Tu solicitud fue enviada a #{vendedor.name}. Te contactará para confirmar el pago."
    else
      redirect_back fallback_location: turista_memberships_path,
                    alert: "No se pudo crear la reserva: #{subscription.errors.full_messages.join(', ')}"
    end
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to subscriptions_path, notice: "Suscripción actualizada correctamente."
    else
      render :edit
    end
  end

  def destroy
    set_subscription
    @subscription.destroy
    redirect_to subscriptions_path, notice: "Suscripción eliminada."
  end

  # Admin aprueba
  def approve
    if current_user.administrador?
      @subscription.set_dates
      @subscription.status = :activada
      @subscription.save
      redirect_to subscriptions_path, notice: "Suscripción aprobada."
    else
      redirect_to subscriptions_path, alert: "No autorizado."
    end
  end

  def cancel
    # @subscription = Subscription.find(params[:id])

    # Validar permisos
    if current_user.administrador? || @subscription.user_id == current_user.id
      @subscription.update(status: "cancelada") # asumiendo que tienes enum :status
      redirect_to subscriptions_path, notice: "La suscripción fue cancelada con éxito."
    else
      redirect_to subscriptions_path, alert: "No tienes permisos para cancelar esta suscripción."
    end
  end

  def establishments_for_user
    user = User.find(params[:user_id])
    establishments = user.establishments

    render json: establishments.select(:id, :name)
  end

  def selector
    if current_user.administrador?
    else
      # @subscriptions = current_user.subscriptions
      redirect_to root_path
    end
  end

  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:establishment_id, :plan_type, :payment_method, :payment_instructions, :status)
  end
end
