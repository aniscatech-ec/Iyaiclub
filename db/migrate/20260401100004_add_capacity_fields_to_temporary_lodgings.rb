class AddCapacityFieldsToTemporaryLodgings < ActiveRecord::Migration[7.1]
  def change
    add_column :temporary_lodgings, :max_guests, :integer
    add_column :temporary_lodgings, :total_rooms, :integer
    add_column :temporary_lodgings, :total_bathrooms, :integer
  end
end
