class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :establishment

  enum :source, {
    booking: 0,
    manual: 1
  }

  validates :visited_at, presence: true

  scope :recent, -> { order(visited_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
end
