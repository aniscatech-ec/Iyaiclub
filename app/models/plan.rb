class Plan < ApplicationRecord
  has_many :plan_prices, dependent: :destroy
end
