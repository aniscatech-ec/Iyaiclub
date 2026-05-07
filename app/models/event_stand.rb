class EventStand < ApplicationRecord
  belongs_to :event
  belongs_to :stand

  validates :stand_id, uniqueness: { scope: :event_id }

  after_create :register_stand_as_autonomo

  private

  def register_stand_as_autonomo
    stand.register_as_autonomo_in(event)
  end
end
