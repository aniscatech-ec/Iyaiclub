class Plan < ApplicationRecord
  has_many :plan_prices, dependent: :destroy

  validates :name, presence: true

  PLAN_TYPES = {
    free: "Free",
    basico: "Básico",
    bronce: "Bronce",
    gold: "Gold",
    platinum: "Platinum",
    gold_estudiantil: "Gold Estudiantil"
  }.freeze

  def plan_type_key
    name&.parameterize&.underscore&.to_sym
  end
end
