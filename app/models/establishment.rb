class Establishment < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  # has_many :establishment_amenities #da error por elimincacion
  # has_many :amenities, through: :establishment_amenities #error por eliminacion
  has_many :establishment_amenities, dependent: :destroy
  has_many :amenities, through: :establishment_amenities
  has_many :subscriptions, as: :subscribable, dependent: :destroy

  after_create :create_verification_record

  # enum :category, hotel: 0, restaurante: 1
  enum :category, EstablishmentTypes::TYPES
  enum :status, { active: 0, inactive: 1 }, default: :inactive
  enum :tipo_gestion_reserva, { autogestion: 0, iyaiclub: 1 }, default: :autogestion
  enum :approval_status, { pending: 0, approved: 1, rejected: 2 }, default: :pending, prefix: :approval

  # ── Validaciones obligatorias según documento de requerimientos ──
  validates :name, presence: { message: "El nombre del establecimiento es obligatorio" }
  validates :category, presence: { message: "Debe seleccionar una categoria" }
  validates :address, presence: { message: "La direccion es obligatoria" }
  validates :phone, presence: { message: "El telefono de contacto es obligatorio" }, unless: :escapada?
  validates :whatsapp, presence: { message: "El enlace de WhatsApp es obligatorio" }, unless: :escapada?
  validates :email, presence: { message: "El correo electronico es obligatorio" }, unless: :escapada?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "El correo no es valido" }, allow_blank: true
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
    val = policies
    return [] if val.blank?
    val.is_a?(Array) ? val : (Array(JSON.parse(val)) rescue [])
  end

  has_many :getaways, dependent: :destroy
  has_many :lodgings, dependent: :destroy
  has_many :experiences, dependent: :destroy
  has_many :promotions, dependent: :destroy

  # ── Foto de portada ──────────────────────────────────────────────────────────
  # Devuelve la imagen de portada seleccionada (por blob_id) o la primera disponible.
  # Busca primero en `images` (has_many_attached) y luego en galleries como fallback.
  def cover_image
    if cover_image_blob_id.present? && images.attached?
      chosen = images.find { |img| img.blob_id == cover_image_blob_id }
      return chosen if chosen
    end
    images.attached? ? images.first : nil
  end

  # Todas las imágenes directas (has_many_attached :images), ordenando la portada primero
  def ordered_images
    return [] unless images.attached?
    all = images.to_a
    if cover_image_blob_id.present?
      cover = all.find { |img| img.blob_id == cover_image_blob_id }
      rest  = all.reject { |img| img.blob_id == cover_image_blob_id }
      cover ? [cover] + rest : all
    else
      all
    end
  end

  # Todas las imágenes para el carousel del hero:
  # primero directas (images), luego las de galleries
  def all_hero_images
    direct = ordered_images
    gallery_imgs = galleries.flat_map { |g| g.gallery_images.select { |gi| gi.file.attached? } }
    { direct: direct, gallery: gallery_imgs }
  end

  private

  def create_verification_record
    create_verification(status: :pending)
  end

end
