class GetawayActivityAssignment < ApplicationRecord
  belongs_to :getaway
  belongs_to :getaway_activity

  validates :getaway_activity_id, uniqueness: { scope: :getaway_id }
end
