class CreateRestaurantTables < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurant_tables do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :table_type
      t.integer :seats, null: false
      t.integer :quantity, default: 1
      t.text :description

      t.timestamps
    end
  end
end
