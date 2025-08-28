class City < ApplicationRecord
  belongs_to :province
  has_many :establishments, dependent: :destroy
end
