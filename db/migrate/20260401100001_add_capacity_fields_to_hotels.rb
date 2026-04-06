class AddCapacityFieldsToHotels < ActiveRecord::Migration[7.1]
  def change
    add_column :hotels, :total_rooms, :integer
    add_column :hotels, :available_rooms, :integer
    add_column :hotels, :max_guests, :integer
  end
end
