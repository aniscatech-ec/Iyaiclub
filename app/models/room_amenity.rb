class RoomAmenity < ApplicationRecord
  belongs_to :room
  belongs_to :amenity

  validates :amenity_id, uniqueness: { scope: :room_id, message: "Esta comodidad ya está asignada a la habitación" }
end
