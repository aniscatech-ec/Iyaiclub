module DynamicPricingHelper
  # Calcula el precio dinámico para un usuario dado según su membresía.
  # Reutiliza `MembershipAccess#total_discount_percentage` ya existente.
  #
  # Retorna un Hash con las claves:
  #   :base             => precio base (Float)
  #   :final            => precio con descuento (Float)
  #   :discount_percent => porcentaje de descuento aplicado (Integer)
  #   :has_discount     => true si hay descuento aplicado
  #   :logged_in        => true si el usuario está autenticado
  #   :membership_name  => nombre de la membresía (String) o nil
  def calculate_dynamic_price(base_price, user = current_user)
    base = base_price.to_f

    if user.blank?
      return {
        base: base,
        final: base,
        discount_percent: 0,
        has_discount: false,
        logged_in: false,
        membership_name: nil
      }
    end

    percent = user.total_discount_percentage.to_i
    final   = (base - (base * percent / 100.0)).round(2)

    {
      base: base,
      final: final,
      discount_percent: percent,
      has_discount: percent.positive?,
      logged_in: true,
      membership_name: user.membership_display_name
    }
  end

  # Renderiza el partial compartido de precio dinámico.
  # size: :sm | :md | :lg  (define la escala tipográfica del partial).
  def render_dynamic_price(base_price, user: current_user, size: :md)
    return "".html_safe if base_price.blank?

    data = calculate_dynamic_price(base_price, user)
    render partial: "shared/dynamic_price", locals: { data: data, size: size }
  end
end
