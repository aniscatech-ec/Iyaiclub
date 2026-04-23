class TourPackage < ApplicationRecord
  belongs_to :travel_agency
  has_many_attached :photos

  validates :name, presence: { message: "El nombre del paquete es obligatorio" }
  validates :price, presence: { message: "El precio es obligatorio" }, numericality: { greater_than_or_equal_to: 0, message: "El precio debe ser un número positivo" }
  validate :validate_photos_limit

  private

  def validate_photos_limit
    if photos.attached? && photos.length > 5
      errors.add(:photos, "Un paquete turístico puede tener máximo 5 fotos.")
    end
  end
end
