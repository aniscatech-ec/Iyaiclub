class Experience < ApplicationRecord
  belongs_to :establishment

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :establishment, presence: true
end
