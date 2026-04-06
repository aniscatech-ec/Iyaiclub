class PointsCalculator
  POINTS_PER_DOLLAR = 1
  MEMBERSHIP_MULTIPLIERS = {
    basico: 1.0,
    premium: 1.5,
    vip: 2.0
  }.freeze

  def initialize(user, amount, establishment, description: nil)
    @user = user
    @amount = amount
    @establishment = establishment
    @description = description || "Puntos por compra"
  end

  def call
    return { success: false, error: "Usuario inválido" } unless @user
    return { success: false, error: "Monto inválido" } unless @amount.to_f > 0
    return { success: false, error: "Establecimiento inválido" } unless @establishment

    points = calculate_points
    user_point = create_user_point(points)

    if user_point.persisted?
      { success: true, points_earned: points, user_point: user_point }
    else
      { success: false, error: user_point.errors.full_messages.join(", ") }
    end
  end

  private

  def calculate_points
    base_points = (@amount.to_f * POINTS_PER_DOLLAR).round
    multiplier = membership_multiplier
    (base_points * multiplier).round
  end

  def membership_multiplier
    membership = @user.active_membership
    return 1.0 unless membership

    plan_type = membership.plan_type&.to_sym
    MEMBERSHIP_MULTIPLIERS[plan_type] || 1.0
  end

  def create_user_point(points)
    @user.user_points.create(
      establishment: @establishment,
      points_earned: points,
      description: @description
    )
  end
end
