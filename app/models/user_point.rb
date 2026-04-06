class UserPoint < ApplicationRecord
  belongs_to :user
  belongs_to :establishment

  validates :points_earned, presence: true, numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
end
