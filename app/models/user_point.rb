class UserPoint < ApplicationRecord
  belongs_to :user
  belongs_to :establishment, optional: true

  enum :source, {
    purchase:   0,  # compra genérica
    booking:    1,  # reserva confirmada
    welcome:    2,  # registro de cuenta
    membership: 3,  # compra de membresía
    invoice:    4,  # factura subida por el usuario y aprobada por admin
    manual:     5   # acreditación manual por admin
  }

  validates :points_earned, presence: true, numericality: { greater_than: 0 }

  scope :recent,   -> { order(created_at: :desc) }
  scope :by_user,  ->(user_id) { where(user_id: user_id) }

  SOURCE_LABELS = {
    "purchase"   => "Compra",
    "booking"    => "Reserva",
    "welcome"    => "Bienvenida",
    "membership" => "Membresía",
    "invoice"    => "Factura",
    "manual"     => "Manual"
  }.freeze

  SOURCE_ICONS = {
    "purchase"   => "fa-shopping-cart",
    "booking"    => "fa-calendar-check",
    "welcome"    => "fa-gift",
    "membership" => "fa-crown",
    "invoice"    => "fa-file-invoice-dollar",
    "manual"     => "fa-user-shield"
  }.freeze

  def source_label
    SOURCE_LABELS[source] || source.humanize
  end

  def source_icon
    SOURCE_ICONS[source] || "fa-star"
  end
end
