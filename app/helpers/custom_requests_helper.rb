module CustomRequestsHelper
  EXPERIENCE_LABELS = {
    "economica" => { label: "Económica", icon: "fas fa-piggy-bank", color: "#3FBD02" },
    "media"     => { label: "Media",     icon: "fas fa-star-half-alt", color: "#88682B" },
    "premium"   => { label: "Premium",   icon: "fas fa-gem", color: "#EB633B" },
    "lujo"      => { label: "Lujo",      icon: "fas fa-crown", color: "#7F5935" }
  }.freeze

  INTEREST_LABELS = {
    "gastronomia"  => { label: "Gastronomía",  icon: "fas fa-utensils" },
    "aventura"     => { label: "Aventura",     icon: "fas fa-hiking" },
    "relax"        => { label: "Relax",        icon: "fas fa-spa" },
    "cultura"      => { label: "Cultura",      icon: "fas fa-landmark" },
    "vida_nocturna"=> { label: "Vida nocturna", icon: "fas fa-cocktail" }
  }.freeze

  PREFERENCE_LABELS = {
    "hoteles"      => { label: "Hoteles",      icon: "fas fa-hotel" },
    "restaurantes" => { label: "Restaurantes", icon: "fas fa-utensils" },
    "transporte"   => { label: "Transporte",   icon: "fas fa-car" },
    "actividades"  => { label: "Actividades",  icon: "fas fa-mountain" }
  }.freeze

  STATUS_BADGE_CLASSES = {
    "pendiente"  => "bg-warning text-dark",
    "en_proceso" => "bg-info text-dark",
    "completado" => "bg-success",
    "cancelado"  => "bg-secondary"
  }.freeze

  def experience_type_label(type)
    EXPERIENCE_LABELS.dig(type.to_s, :label) || type.to_s.titleize
  end

  def experience_type_icon(type)
    EXPERIENCE_LABELS.dig(type.to_s, :icon) || "fas fa-star"
  end

  def experience_type_color(type)
    EXPERIENCE_LABELS.dig(type.to_s, :color) || "#EB633B"
  end

  def interest_label(key)
    INTEREST_LABELS.dig(key.to_s, :label) || key.to_s.titleize
  end

  def interest_icon(key)
    INTEREST_LABELS.dig(key.to_s, :icon) || "fas fa-heart"
  end

  def preference_label(key)
    PREFERENCE_LABELS.dig(key.to_s, :label) || key.to_s.titleize
  end

  def preference_icon(key)
    PREFERENCE_LABELS.dig(key.to_s, :icon) || "fas fa-check"
  end

  def custom_request_status_badge(status)
    css = STATUS_BADGE_CLASSES[status.to_s] || "bg-secondary"
    content_tag :span, status.to_s.humanize, class: "badge rounded-pill #{css}"
  end

  def experience_options_for_select
    CustomRequest.experience_types.keys.map { |k| [experience_type_label(k), k] }
  end
end
