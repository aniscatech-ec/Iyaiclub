class Verification < ApplicationRecord
  belongs_to :establishment

  has_one_attached :identity_document
  has_one_attached :property_document
  has_one_attached :selfie

  enum status: {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  validates :status, presence: true
end
