class Room < ApplicationRecord
  belongs_to :hotel, optional: true
  belongs_to :temporary_lodging, optional: true
  has_many :room_amenities, dependent: :destroy
  has_many :amenities, through: :room_amenities
  has_one_attached :photo

  ROOM_TYPES = %w[individual doble triple cuadruple suite familiar].freeze
  BED_TYPES = %w[1_plaza plaza_y_media doble queen king].freeze

  validates :name, presence: { message: "El nombre de la habitación es obligatorio" }
  validates :price_per_night, numericality: { greater_than: 0, message: "El precio debe ser mayor a 0" }, allow_nil: true
  validates :guest_capacity, numericality: { only_integer: true, greater_than: 0, message: "La capacidad debe ser mayor a 0" }, allow_nil: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 50, message: "La cantidad debe ser entre 1 y 50" }
  validates :num_beds, numericality: { only_integer: true, greater_than: 0, message: "El número de camas debe ser mayor a 0" }, allow_nil: true
  validates :room_type, inclusion: { in: ROOM_TYPES, message: "Tipo de habitación no válido" }, allow_blank: true
  validates :bed_type, inclusion: { in: BED_TYPES, message: "Tipo de cama no válido" }, allow_blank: true
  validate :must_belong_to_one_parent

  private

  def must_belong_to_one_parent
    if hotel_id.blank? && temporary_lodging_id.blank?
      errors.add(:base, "La habitación debe pertenecer a un hotel o alojamiento temporal")
    end
  end
end
