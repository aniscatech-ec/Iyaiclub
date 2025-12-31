class CreateRestaurantHours < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurant_hours do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.integer :day_of_week
      t.time :open_time
      t.time :close_time
      t.boolean :closed

      t.timestamps
    end
  end
end
