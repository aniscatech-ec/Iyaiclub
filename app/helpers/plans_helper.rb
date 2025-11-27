module PlansHelper

  # Convierte el string JSON a un hash Ruby
  def parse_features(plan)
    JSON.parse(plan.features || "{}") rescue {}
  end

  # Traduce una característica según su clave y valor
  def feature_text(key, value)
    case key
    when "max_photos"
      value == "unlimited" ? "Fotos ilimitadas" : "Hasta #{value} fotos"

    when "highlighted_listing"
      value ? "Destacado en listados" : "Sin destacar en listados"

    when "advanced_reports"
      value ? "Reportes avanzados" : "Reportes básicos"

    when "premium_ads"
      value ? "Anuncios premium" : nil

    when "deep_analytics"
      value ? "Analíticas profundas" : nil

    when "support_level"
      case value
      when "standard" then "Soporte estándar"
      when "priority" then "Soporte prioritario"
      when "24/7"     then "Soporte 24/7"
      else
        "Soporte #{value}"
      end

    else
      # fallback para cualquier feature futuro
      "#{key.humanize}: #{value}"
    end
  end

end

