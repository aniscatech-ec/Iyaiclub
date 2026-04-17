class PointsCalculator
  # Crea un registro de UserPoint para un usuario dado un monto y contexto.
  # Usa el ratio de puntos de MembershipAccess según el plan activo del usuario.
  #
  # Uso:
  #   PointsCalculator.call(user, amount: 90, source: :booking,
  #                         establishment: est, description: "Reserva hotel X")
  #
  # También puede usarse para puntos sin monto (bienvenida, membresía):
  #   PointsCalculator.grant(user, points: 500, source: :welcome,
  #                          description: "Puntos de bienvenida")

  def self.call(user, amount:, source: :purchase, establishment: nil, description: nil)
    new(user).call_with_amount(amount, source: source, establishment: establishment, description: description)
  end

  def self.grant(user, points:, source:, description:, establishment: nil)
    new(user).grant_fixed(points, source: source, description: description, establishment: establishment)
  end

  def initialize(user)
    @user = user
  end

  def call_with_amount(amount, source:, establishment:, description:)
    return error("Usuario inválido") unless @user
    return error("Monto debe ser mayor a 0") unless amount.to_f > 0

    points = @user.calculate_points_for_amount(amount.to_f).round
    return error("Puntos calculados son 0") if points <= 0

    create_point(points, source: source, establishment: establishment,
                 description: description || default_description(source, amount))
  end

  def grant_fixed(points, source:, description:, establishment: nil)
    return error("Usuario inválido") unless @user
    return error("Puntos deben ser mayor a 0") unless points.to_i > 0

    create_point(points.to_i, source: source, establishment: establishment,
                 description: description)
  end

  private

  def create_point(points, source:, establishment:, description:)
    user_point = @user.user_points.create(
      points_earned: points,
      source: source,
      establishment: establishment,
      description: description
    )

    if user_point.persisted?
      { success: true, points_earned: points, user_point: user_point }
    else
      error(user_point.errors.full_messages.join(", "))
    end
  end

  def default_description(source, amount)
    case source.to_sym
    when :booking    then "Puntos por reserva ($#{amount})"
    when :purchase   then "Puntos por compra ($#{amount})"
    when :welcome    then "Puntos de bienvenida"
    when :membership then "Puntos por adquirir membresía"
    when :invoice    then "Puntos por factura ($#{amount})"
    else "Puntos acreditados"
    end
  end

  def error(msg)
    { success: false, error: msg }
  end
end
