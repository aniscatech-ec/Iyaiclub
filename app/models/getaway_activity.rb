class GetawayActivity < ApplicationRecord
  has_many :getaway_activity_assignments, dependent: :destroy
  has_many :getaways, through: :getaway_activity_assignments

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position, :name) }

  # Actividades predeterminadas para seed
  DEFAULTS = [
    { name: "Senderismo",         icon: "fa-hiking" },
    { name: "Deportes Extremos",  icon: "fa-parachute-box" },
    { name: "Acampada",           icon: "fa-campground" },
    { name: "Ciclismo",           icon: "fa-bicycle" },
    { name: "Escalada",           icon: "fa-mountain" },
    { name: "Natación",           icon: "fa-swimming-pool" },
    { name: "Pesca",              icon: "fa-fish" },
    { name: "Kayak / Canoa",      icon: "fa-water" },
    { name: "Tirolesa",           icon: "fa-wind" },
    { name: "Observación de aves",icon: "fa-feather-alt" },
    { name: "Fotografía",         icon: "fa-camera" },
    { name: "Turismo cultural",   icon: "fa-landmark" },
    { name: "Picnic",             icon: "fa-utensils" },
    { name: "Juegos al aire libre", icon: "fa-futbol" },
    { name: "Rappel",             icon: "fa-anchor" },
  ].freeze
end
