class AddHotelIdToUnits < ActiveRecord::Migration[8.0]
  def change
    add_reference :units, :hotel, null: false, foreign_key: true
  end
end
