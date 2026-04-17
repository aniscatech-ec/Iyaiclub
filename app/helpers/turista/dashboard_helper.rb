module Turista::DashboardHelper
  def status_color(status)
    case status&.to_sym
    when :confirmado then "var(--brand-green)"
    when :pendiente then "#ffc107"
    when :cancelado, :rechazado then "#dc3545"
    else "#6c757d"
    end
  end

  def status_badge_class(status)
    case status&.to_sym
    when :confirmado then "success"
    when :pendiente then "warning"
    when :cancelado, :rechazado then "danger"
    else "secondary"
    end
  end

  def reward_icon(category)
    case category&.to_sym
    when :descuento then "fa-percent"
    when :producto then "fa-gift"
    when :servicio then "fa-concierge-bell"
    when :experiencia then "fa-hiking"
    else "fa-star"
    end
  end

  def membership_gradient(plan_name)
    case plan_name&.downcase
    when /gold/, /vip/       then "#FFD700, #FFA500"
    when /platinum/, /premium/ then "#8B5CF6, #6366F1"
    when /bronce/             then "#CD7F32, #a0522d"
    else "var(--brand-green), #2a8c00"
    end
  end

  def redemption_status_class(status)
    case status&.to_sym
    when :entregado then "success"
    when :aprobado then "info"
    when :pendiente then "warning"
    when :rechazado then "danger"
    else "secondary"
    end
  end
end
