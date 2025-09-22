class PricingPolicy < ApplicationRecord
  belongs_to :establishment

  def refund_policy_array
    refund_policy || []
  end
end
