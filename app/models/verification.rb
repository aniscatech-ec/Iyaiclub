class Verification < ApplicationRecord
  belongs_to :establishment

  has_one_attached :identity_document
  has_one_attached :property_document
  has_one_attached :selfie
end
