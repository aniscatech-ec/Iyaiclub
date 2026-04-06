class AddCapacityFieldsToRestaurants < ActiveRecord::Migration[7.1]
  def change
    add_column :restaurants, :total_tables, :integer
    add_column :restaurants, :seats_per_table, :integer
    add_column :restaurants, :available_tables, :integer
    add_column :restaurants, :total_capacity, :integer
  end
end
