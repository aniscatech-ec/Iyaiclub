class VisitTracker
  def initialize(user, establishment, source: :booking)
    @user = user
    @establishment = establishment
    @source = source
  end

  def call
    return { success: false, error: "Usuario inválido" } unless @user
    return { success: false, error: "Establecimiento inválido" } unless @establishment

    visit = create_or_find_visit

    if visit.persisted?
      { success: true, visit: visit, new_record: visit.previously_new_record? }
    else
      { success: false, error: visit.errors.full_messages.join(", ") }
    end
  end

  def self.track_from_booking(booking)
    return unless booking.confirmado?
    return unless booking.unit&.establishment

    user = User.find_by(email: booking.guest_email)
    return unless user

    new(user, booking.unit.establishment, source: :booking).call
  end

  private

  def create_or_find_visit
    existing = @user.visits.find_by(
      establishment: @establishment,
      visited_at: Date.current.beginning_of_day..Date.current.end_of_day
    )

    return existing if existing

    @user.visits.create(
      establishment: @establishment,
      visited_at: Time.current,
      source: @source
    )
  end
end
