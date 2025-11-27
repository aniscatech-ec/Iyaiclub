class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[show edit update destroy approve cancel]
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: %i[selector]

  layout "dashboard"

  # Afiliado ve las suyas, Admin ve todas
  def index
    if current_user.administrador?
      @subscriptions = Subscription.all
    else current_user.afiliado?
      # @subscriptions = current_user.subscriptions
      # @subscriptions = Subscription.joins(:establishment).where(establishments: { user_id: current_user.id })
      # Obtener los establecimientos del afiliado
    establishments = current_user.establishments

      # Traer solo sus suscripciones (polimórfico)
    @subscriptions = Subscription
                       .where(subscribable: establishments)
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
      # @plans = PlanPrice.where(target_role: current_user.role)
      @plan_prices = PlanPrice.where(target_role: current_user.role)

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
    @plan_price = PlanPrice.find(params[:plan_id])

    if current_user.administrador?
      @establishments = Establishment.all
    elsif current_user.afiliado?
      @establishment = current_user.establishments.find(params[:establishment_id])
    elsif current_user.turista?

    end
  end

  def create
    @subscription = Subscription.new(subscription_params)

    puts subscription_params
    # @subscription.user = current_user
    @subscription.status = :pendiente
    if current_user.administrador?
      # @establishments = Establishment.all
    elsif current_user.afiliado?
      @establishment = current_user.establishments.find(subscription_params[:subscribable_id])
    elsif current_user.turista?

    end


    if @subscription.save
      redirect_to @subscription, notice: "Solicitud enviada. Sigue las instrucciones de pago."
    else
      render :new, status: :unprocessable_entity
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
    params.require(:subscription).permit(:establishment_id, :plan_type, :payment_method, :payment_instructions, :status, :subscribable_type, :subscribable_id)
  end
end
