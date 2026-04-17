class PlanVendedor < ApplicationRecord
  belongs_to :plan
  belongs_to :vendedor, class_name: "User"

  validates :plan_id, uniqueness: { scope: :vendedor_id, message: "ya tiene este vendedor asignado" }
end
