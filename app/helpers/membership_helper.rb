module MembershipHelper
  def membership_required(min_level = :basico, &block)
    if current_user&.has_membership?(min_level)
      capture(&block)
    else
      render partial: "shared/membership_upgrade_prompt",
             locals: { required_level: min_level }
    end
  end

  def show_if_member(min_level = :basico, &block)
    capture(&block) if current_user&.has_membership?(min_level)
  end

  def hide_if_free(&block)
    capture(&block) unless current_user&.is_free_member?
  end

  def membership_badge(user = current_user)
    return content_tag(:span, "Sin cuenta", class: "badge bg-secondary") unless user

    level = user.membership_level
    badge_class = user.membership_badge_class
    content_tag(:span, user.membership_display_name, class: "badge #{badge_class}")
  end

  def membership_level_icon(level)
    icons = {
      free: "fa-user",
      basico: "fa-star",
      bronce: "fa-medal",
      gold: "fa-crown",
      platinum: "fa-gem",
      gold_estudiantil: "fa-graduation-cap"
    }
    icons[level&.to_sym] || "fa-user"
  end

  def membership_discount_badge(user = current_user)
    return unless user&.can_access_discounts?

    discount = user.discount_percentage
    fixed = user.fixed_discount_percentage

    content = if fixed > 0
                "#{discount}% + #{fixed}% fijo"
              else
                "Hasta #{discount}%"
              end

    content_tag(:span, class: "badge bg-success") do
      concat content_tag(:i, "", class: "fas fa-tag me-1")
      concat content
    end
  end

  def points_ratio_display(user = current_user)
    return "1 punto por cada $5" unless user

    ratio = user.points_ratio
    "#{ratio[:points]} #{ratio[:points] == 1 ? 'punto' : 'puntos'} por cada $#{ratio[:per_dollars]}"
  end

  def pool_benefits_display(user = current_user)
    return "No disponible" unless user&.can_access_pool_visits?

    benefits = user.pool_benefits
    "#{benefits[:visits]} visitas/año, hasta #{benefits[:max_guests]} personas, nivel #{benefits[:level]}"
  end

  def free_nights_display(user = current_user)
    return "No disponible" unless user&.can_access_free_nights?

    benefits = user.free_nights_benefits
    extras = []
    extras << "desayuno" if benefits[:breakfast]
    extras << "cena" if benefits[:dinner]

    base = "#{benefits[:nights]} noches y #{benefits[:days]} días para #{benefits[:max_guests]} personas"
    extras.any? ? "#{base} (incluye #{extras.join(' y ')})" : base
  end

  def membership_comparison_table(plans)
    render partial: "shared/membership_comparison_table", locals: { plans: plans }
  end

  def upgrade_cta_button(target_level = :basico, size: "md")
    btn_class = "btn btn-warning btn-#{size}"
    link_to turista_memberships_path, class: btn_class do
      concat content_tag(:i, "", class: "fas fa-crown me-1")
      concat "Mejorar a #{target_level.to_s.humanize}"
    end
  end
end
