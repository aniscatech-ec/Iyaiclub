class Reward < ApplicationRecord
  belongs_to :establishment, optional: true
  has_many :redemptions, dependent: :destroy

  enum :category, {
    descuento: 0,
    producto: 1,
    servicio: 2,
    experiencia: 3
  }

  validates :name, presence: true
  validates :points_required, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat) }
end
