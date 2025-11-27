class Subscription < ApplicationRecord
  # belongs_to :establishment
  belongs_to :subscribable, polymorphic: true

  # enum :plan_type, basico: 0, vip: 1
  # enum :duration,  mensual: 0, anual: 2
  enum :status, pendiente: 0, activada: 1, vencida: 2, cancelada: 3
  enum :payment_method, transferencia: 0, tarjeta: 1, efectivo: 2
  has_many :payment_receipts, dependent: :destroy

  # Calcula fecha de fin según duración
  def set_dates
    self.start_date = Date.today
    self.end_date = case PlanPrice.find(self.plan_type).duration
                    when 1 then start_date + 1.month
                    when 6 then start_date + 6.month
                    when 12 then start_date + 1.year
                    end
  end

  PAYMENT_TEMPLATES = {
    "efectivo" => "Diríjase a nuestra oficina principal y realice el pago en ventanilla. Dirección: Calle Ejemplo 123.",
    "transferencia" => "Banco Ejemplo\nCuenta Corriente: 1234567890\nTitular: Empresa Ejemplo S.A.\nRUC: 1234567890001\nEnvie comprobante a pagos@empresa.com",
    "tarjeta" => "Pague con tarjeta de crédito o débito en el siguiente enlace: https://pagos.empresa.com"
  }.freeze
  def active?
    return false if start_date.blank? || end_date.blank?
    Date.current.between?(start_date, end_date)
  end
  # def calculate_amount
  #   price_record = PlanPrice.find_by(plan_type: plan_type, duration: duration)
  #   self.amount = price_record&.price || 0
  # end
  #
  # before_validation :calculate_amount

  # validate :only_one_active_subscription, on: :create
  #
  # def only_one_active_subscription
  #   if establishment.subscriptions.where(status: "activada").exists?
  #     errors.add(:base, "Este establecimiento ya tiene una suscripción activa")
  #   end
  # end

  def only_one_active_subscription
    return unless subscribable_type == "Establishment"

    if subscribable.subscriptions.where(status: :activada).exists?
      errors.add(:base, "Este establecimiento ya tiene una suscripción activa")
    end
  end


  def affiliate
    establishment.user
  end

  # Ejemplo: saber si es turista o afiliado
  def for_tourist?
    subscribable_type == "User"
  end

  def for_establishment?
    subscribable_type == "Establishment"
  end

  validate :only_one_active_subscription_for_tourist, on: :create
  validate :only_one_active_subscription_for_establishment, on: :create

  private

  def only_one_active_subscription_for_tourist
    return unless subscribable_type == "User"

    if subscribable.subscriptions.where(status: :activada).exists?
      errors.add(:base, "El turista ya tiene una suscripción activa")
    end
  end

  def only_one_active_subscription_for_establishment
    return unless subscribable_type == "Establishment"

    if subscribable.subscriptions.where(status: :activada).exists?
      errors.add(:base, "Este establecimiento ya tiene una suscripción activa")
    end
  end


end
