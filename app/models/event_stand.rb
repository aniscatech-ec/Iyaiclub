class EventStand < ApplicationRecord
  belongs_to :event
  belongs_to :stand

  validates :stand_id, uniqueness: { scope: :event_id }
end
