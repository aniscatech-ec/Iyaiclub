class AddRoomToBookings < ActiveRecord::Migration[8.0]
  def change
    # Hacer unit_id opcional
    change_column_null :bookings, :unit_id, true
    
    # Agregar room_id
    add_reference :bookings, :room, null: true, foreign_key: true
  end
end
