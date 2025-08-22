class PlanPrice < ApplicationRecord
  # enum :plan_type, basico: 0, vip: 1
  # enum :duration, uno: 0, seis: 1, doce:2
  # DURATION_OPTIONS = [["Mensual", 1], ["Anual", 12]].freeze

  # validates :plan_type, presence: true
  # validates :duration, presence: true, inclusion: { in: [1, 12] }
  # validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  enum :target_role, afiliado: 0, turista: 1

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
