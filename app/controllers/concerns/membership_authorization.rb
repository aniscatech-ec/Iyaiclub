module MembershipAuthorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_membership_level, :current_user_is_member?
  end

  def current_membership_level
    current_user&.membership_level || :free
  end

  def current_user_is_member?(min_level = :basico)
    current_user&.has_membership?(min_level)
  end

  def require_membership!(min_level = :basico)
    unless current_user&.has_membership?(min_level)
      respond_to do |format|
        format.html do
          redirect_to turista_memberships_path,
            alert: "Esta función requiere membresía #{min_level.to_s.humanize} o superior"
        end
        format.json do
          render json: { error: "Membresía requerida", required_level: min_level }, status: :forbidden
        end
      end
    end
  end

  def require_basic_membership!
    require_membership!(:basico)
  end

  def require_bronce_membership!
    require_membership!(:bronce)
  end

  def require_gold_membership!
    require_membership!(:gold)
  end

  def require_platinum_membership!
    require_membership!(:platinum)
  end

  def require_paid_membership!
    unless current_user&.is_paid_member?
      redirect_to turista_memberships_path,
        alert: "Esta función requiere una membresía activa"
    end
  end

  def membership_discount_for(base_price)
    return base_price unless current_user&.can_access_discounts?

    discount = current_user.total_discount_percentage
    base_price * (1 - discount / 100.0)
  end

  def calculate_points_earned(amount)
    return 0 unless current_user

    current_user.calculate_points_for_amount(amount)
  end
end
