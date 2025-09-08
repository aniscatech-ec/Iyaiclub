class Country < ApplicationRecord
  has_many :provinces, dependent: :destroy
  has_many :users
  has_many :cities, through: :provinces
end
