class ReferralRewardConfig < ApplicationRecord
  validates :reward_type, presence: true, inclusion: { in: %w[membership ticket] }
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.points_for(reward_type)
    find_by(reward_type: reward_type)&.points.to_i
  end
end
