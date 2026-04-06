class Redemption < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  enum :status, {
    pendiente: 0,
    aprobado: 1,
    entregado: 2,
    rechazado: 3
  }

  validates :points_used, presence: true, numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
end
