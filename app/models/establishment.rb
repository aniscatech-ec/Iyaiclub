class Establishment < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  enum :category, hotel: 0, restaurante: 1

  validates :name, :description, :category, presence: true
end
