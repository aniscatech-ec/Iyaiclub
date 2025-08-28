class Province < ApplicationRecord
  has_many :cities, dependent: :destroy
end
