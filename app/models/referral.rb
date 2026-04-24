class Referral < ApplicationRecord
  belongs_to :referrer, class_name: "User"
  belongs_to :referred, class_name: "User", optional: true
  belongs_to :source, polymorphic: true, optional: true

  validates :reward_type, presence: true, inclusion: { in: %w[membership ticket] }
  validates :status, presence: true, inclusion: { in: %w[pendiente acreditado cancelado] }
  # Garantía a nivel de modelo: un mismo source solo puede generar un referido.
  validates :source_id, uniqueness: { scope: :source_type,
                                      message: "ya tiene un referido acreditado" },
                         allow_nil: true

  scope :acreditados, -> { where(status: "acreditado") }

  # Registra un referido exitoso y otorga los puntos al referidor.
  # Llamado tras confirmar el pago o acreditar transferencia.
  # Idempotente: si el source ya tiene un referido acreditado, no hace nada.
  def self.process(referral_code:, reward_type:, referred_user: nil, referred_email: nil, source: nil)
    referrer = User.find_by(referral_code: referral_code.to_s.upcase)
    return unless referrer

    points = ReferralRewardConfig.points_for(reward_type)
    return if points <= 0

    # Guardia anti-duplicado: si este source ya fue procesado, salir silenciosamente.
    if source.present? && exists?(source: source)
      Rails.logger.warn("[Referral] Intento de doble acreditación ignorado — " \
                        "source=#{source.class.name}##{source.id}, code=#{referral_code}")
      return nil
    end

    referral = create!(
      referrer:        referrer,
      referred:        referred_user,
      referred_email:  referred_email || referred_user&.email,
      reward_type:     reward_type,
      points_awarded:  points,
      status:          "acreditado",
      source:          source
    )

    PointsCalculator.grant(
      referrer,
      points:      points,
      source:      :manual,
      description: "Referido exitoso (#{reward_type == 'membership' ? 'membresía' : 'ticket'}) — #{referral.referred_email}"
    )

    referral
  rescue ActiveRecord::RecordNotUnique
    # El índice único de BD rechazó una inserción concurrente (race condition).
    Rails.logger.warn("[Referral] Race condition detectada y bloqueada por índice único — " \
                      "source=#{source&.class&.name}##{source&.id}, code=#{referral_code}")
    nil
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[Referral] Error procesando referido: #{e.message}")
    nil
  end
end
