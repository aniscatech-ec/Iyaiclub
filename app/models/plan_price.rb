class PlanPrice < ApplicationRecord
  belongs_to :plan, optional: true

  enum :target_role, afiliado: 0, turista: 1

  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def display_name
    if duration == 1
      "#{plan_type.humanize} - #{duration} mes - $ #{price}"
    else
      "#{plan_type.humanize} - #{duration} meses - $ #{price}"
    end
  end

  def display_duration
    if duration == 1
      "#{duration} mes"
    else
      "#{duration} meses"
    end
  end
end
