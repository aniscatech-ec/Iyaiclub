class AddTemporaryLodgingToRooms < ActiveRecord::Migration[8.0]
  def change
    # Hacer hotel_id nullable para permitir rooms de temporary_lodgings
    change_column_null :rooms, :hotel_id, true

    add_reference :rooms, :temporary_lodging, null: true, foreign_key: true
  end
end
