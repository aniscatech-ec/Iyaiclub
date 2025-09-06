class UnitPrice < ApplicationRecord
  belongs_to :unit

  enum :season, low: "low", high: "high", special: "special"

end
