class Referral < ApplicationRecord
  belongs_to :referrer, class_name: "User"
  belongs_to :referred, class_name: "User", optional: true
  belongs_to :source, polymorphic: true, optional: true

  validates :reward_type, presence: true, inclusion: { in: %w[membership ticket] }
  validates :status, presence: true, inclusion: { in: %w[pendiente acreditado cancelado] }

  scope :acreditados, -> { where(status: "acreditado") }

  # Registra un referido exitoso y otorga los puntos al referidor.
  # Llamado tras confirmar el pago o acreditar transferencia.
  def self.process(referral_code:, reward_type:, referred_user: nil, referred_email: nil, source: nil)
    referrer = User.find_by(referral_code: referral_code.to_s.upcase)
    return unless referrer

    points = ReferralRewardConfig.points_for(reward_type)
    return if points <= 0

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
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[Referral] Error procesando referido: #{e.message}")
    nil
  end
end
