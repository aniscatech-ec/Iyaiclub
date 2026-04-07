module MembershipAccess
  extend ActiveSupport::Concern

  PLAN_LEVELS = {
    free: 0,
    basico: 1,
    bronce: 2,
    gold: 3,
    platinum: 4,
    gold_estudiantil: 3
  }.freeze

  PLAN_DISCOUNTS = {
    free: 0,
    basico: 20,
    bronce: 30,
    gold: 35,
    platinum: 50,
    gold_estudiantil: 35
  }.freeze

  POINTS_RATIOS = {
    free: { points: 1, per_dollars: 5 },
    basico: { points: 2, per_dollars: 3 },
    bronce: { points: 3, per_dollars: 2 },
    gold: { points: 5, per_dollars: 2 },
    platinum: { points: 2, per_dollars: 1 },
    gold_estudiantil: { points: 5, per_dollars: 2 }
  }.freeze

  POOL_BENEFITS = {
    free: { visits: 0, level: 0, max_guests: 0 },
    basico: { visits: 3, level: 1, max_guests: 3 },
    bronce: { visits: 4, level: 2, max_guests: 4 },
    gold: { visits: 5, level: 2, max_guests: 4 },
    platinum: { visits: 6, level: 2, max_guests: 4 },
    gold_estudiantil: { visits: 6, level: 2, max_guests: 1 }
  }.freeze

  FREE_NIGHTS = {
    free: { nights: 0, days: 0, max_guests: 0, breakfast: false, dinner: false },
    basico: { nights: 1, days: 2, max_guests: 2, breakfast: false, dinner: false },
    bronce: { nights: 2, days: 3, max_guests: 2, breakfast: false, dinner: false },
    gold: { nights: 3, days: 2, max_guests: 2, breakfast: true, dinner: false },
    platinum: { nights: 3, days: 4, max_guests: 4, breakfast: true, dinner: true },
    gold_estudiantil: { nights: 2, days: 3, max_guests: 3, breakfast: true, dinner: false }
  }.freeze

  def membership_plan_type
    return :free unless active_membership

    plan_price = PlanPrice.find_by(id: active_membership.plan_type)
    return :free unless plan_price

    plan_price.plan_type&.to_sym || :free
  end

  def membership_level
    membership_plan_type
  end

  def membership_level_value
    PLAN_LEVELS[membership_level] || 0
  end

  def has_membership?(min_level = :basico)
    membership_level_value >= (PLAN_LEVELS[min_level] || 0)
  end

  def is_free_member?
    membership_level == :free
  end

  def is_paid_member?
    has_membership?(:basico)
  end

  def can_access_discounts?
    has_membership?(:basico)
  end

  def can_access_events?
    has_membership?(:basico)
  end

  def can_redeem_points_fully?
    has_membership?(:basico)
  end

  def can_access_free_nights?
    has_membership?(:basico)
  end

  def can_access_pool_visits?
    has_membership?(:basico)
  end

  def has_fixed_discount?
    membership_level == :gold
  end

  def discount_percentage
    PLAN_DISCOUNTS[membership_level] || 0
  end

  def fixed_discount_percentage
    has_fixed_discount? ? 5 : 0
  end

  def total_discount_percentage
    discount_percentage + fixed_discount_percentage
  end

  def points_ratio
    POINTS_RATIOS[membership_level] || POINTS_RATIOS[:free]
  end

  def points_per_dollar
    ratio = points_ratio
    ratio[:points].to_f / ratio[:per_dollars]
  end

  def calculate_points_for_amount(amount)
    ratio = points_ratio
    (amount / ratio[:per_dollars]) * ratio[:points]
  end

  def pool_benefits
    POOL_BENEFITS[membership_level] || POOL_BENEFITS[:free]
  end

  def pool_visits_per_year
    pool_benefits[:visits]
  end

  def pool_level_access
    pool_benefits[:level]
  end

  def max_pool_guests
    pool_benefits[:max_guests]
  end

  def free_nights_benefits
    FREE_NIGHTS[membership_level] || FREE_NIGHTS[:free]
  end

  def free_nights_per_year
    free_nights_benefits[:nights]
  end

  def free_days_per_year
    free_nights_benefits[:days]
  end

  def includes_breakfast?
    free_nights_benefits[:breakfast]
  end

  def includes_dinner?
    free_nights_benefits[:dinner]
  end

  def max_lodging_guests
    free_nights_benefits[:max_guests]
  end

  def membership_display_name
    case membership_level
    when :free then "Free"
    when :basico then "Básico"
    when :bronce then "Bronce"
    when :gold then "Gold"
    when :platinum then "Platinum"
    when :gold_estudiantil then "Gold Estudiantil"
    else "Free"
    end
  end

  def membership_badge_class
    case membership_level
    when :free then "bg-secondary"
    when :basico then "bg-info"
    when :bronce then "bg-warning text-dark"
    when :gold then "bg-warning"
    when :platinum then "bg-dark"
    when :gold_estudiantil then "bg-success"
    else "bg-secondary"
    end
  end
end
