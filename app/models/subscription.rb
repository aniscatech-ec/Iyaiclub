class Subscription < ApplicationRecord
  # belongs_to :establishment
  belongs_to :subscribable, polymorphic: true

  # enum :plan_type, basico: 0, vip: 1
  # enum :duration,  mensual: 0, anual: 2
  enum :status, pendiente: 0, activada: 1, vencida: 2, cancelada: 3
  enum :payment_method, transferencia: 0, tarjeta: 1, efectivo: 2
  # cancellation_type: 0 = por_usuario (cancela pero mantiene beneficios hasta end_date),
  #                    1 = por_admin, 2 = por_impago (se activa prórroga de 5 días)
  enum :cancellation_type, por_usuario: 0, por_admin: 1, por_impago: 2

  GRACE_PERIOD_DAYS = 5

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

  def plan_name
    PlanPrice.find_by(id: plan_type)&.plan&.name || "Sin plan"
  end

  # El usuario cancela voluntariamente: se marca cancelled_at pero mantiene
  # el status :activada hasta que venza end_date (los beneficios siguen activos).
  def cancel_by_user!
    update!(
      cancelled_at: Time.current,
      cancellation_type: :por_usuario
    )
  end

  # ¿El usuario ya solicitó cancelación pero el período aún está vigente?
  def pending_cancellation?
    cancelled_at.present? && activada? && end_date >= Date.current
  end

  # ¿Está en período de prórroga por impago?
  def in_grace_period?
    grace_period_until.present? && Date.current <= grace_period_until
  end

  # ¿Está dentro de los últimos N días antes de vencer?
  def expiring_soon?(days = 7)
    activada? && end_date.present? && end_date.between?(Date.current, Date.current + days.days)
  end

  # Inicia prórroga de 5 días por impago y cambia tipo de cancelación
  def start_grace_period!
    update!(
      grace_period_until: Date.current + GRACE_PERIOD_DAYS.days,
      cancellation_type: :por_impago
    )
  end

  # Expira la membresía definitivamente (fin de prórroga o fin normal)
  def expire!
    update!(status: :vencida)
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
