class Unit < ApplicationRecord
  belongs_to :establishment
  store :seasonal_prices, accessors: [:high, :low], coder: JSON

end
