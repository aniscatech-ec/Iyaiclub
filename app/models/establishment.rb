class Establishment < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  # has_many :establishment_amenities #da error por elimincacion
  # has_many :amenities, through: :establishment_amenities #error por eliminacion
  has_many :establishment_amenities, dependent: :destroy
  has_many :amenities, through: :establishment_amenities
  has_many :subscriptions, as: :subscribable, dependent: :destroy

  # enum :category, hotel: 0, restaurante: 1
  enum :category, EstablishmentTypes::TYPES
  enum :status, { active: 0, inactive: 1 }, default: :active
  enum :tipo_gestion_reserva, { autogestion: 0, iyaiclub: 1 }, default: :autogestion

  # ── Validaciones obligatorias según documento de requerimientos ──
  validates :name, presence: { message: "El nombre del establecimiento es obligatorio" }
  validates :category, presence: { message: "Debe seleccionar una categoria" }
  validates :address, presence: { message: "La direccion es obligatoria" }
  validates :phone, presence: { message: "El telefono de contacto es obligatorio" }
  validates :whatsapp, presence: { message: "El enlace de WhatsApp es obligatorio" }
  validates :email, presence: { message: "El correo electronico es obligatorio" },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "El correo no es valido", allow_blank: true }
  validates :latitude, presence: { message: "La latitud es obligatoria (ubicacion en Google Maps)" }
  validates :longitude, presence: { message: "La longitud es obligatoria (ubicacion en Google Maps)" }
  validates :country_id, presence: { message: "Debe seleccionar un pais" }
  validates :province_id, presence: { message: "Debe seleccionar una provincia" }
  validates :city_id, presence: { message: "Debe seleccionar una ciudad" }

  belongs_to :city
  belongs_to :province
  belongs_to :country


  has_one :hotel, dependent: :destroy
  has_one :restaurant, dependent: :destroy
  has_one :transport, dependent: :destroy
  has_one :temporary_lodging, dependent: :destroy
  has_one :legal_info, dependent: :destroy
  has_one :verification, dependent: :destroy

  has_many :units, dependent: :destroy
  has_many :payment_methods, dependent: :destroy
  has_many :galleries, dependent: :destroy
  has_many :booking_requests, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :user_points, dependent: :destroy
  has_many :visits, dependent: :destroy

  accepts_nested_attributes_for :legal_info
  accepts_nested_attributes_for :verification
  accepts_nested_attributes_for :units
  accepts_nested_attributes_for :payment_methods
  # accepts_nested_attributes_for :galleries
  accepts_nested_attributes_for :galleries, allow_destroy: true,
                                            reject_if: :reject_gallery_without_images?

  def reject_gallery_without_images?(attrs)
    return true if attrs["id"].blank? && attrs["name"].blank? &&
                   (attrs["gallery_images_attributes"].blank? ||
                    attrs["gallery_images_attributes"].values.all? { |ia| ia["file"].blank? && ia["id"].blank? })
    attrs["name"] = "Galería" if attrs["name"].blank?
    false
  end
  has_one :pricing_policy, dependent: :destroy
  accepts_nested_attributes_for :pricing_policy

  has_one_attached :video
  # Devuelve [] si policies es nil
  def policies_array
    policies || []
  end

  has_many :getaways, dependent: :destroy
  has_many :lodgings, dependent: :destroy
  has_many :experiences, dependent: :destroy




end
