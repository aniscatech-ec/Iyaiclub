class CreateRestaurantMenuCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurant_menu_categories do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :menu_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
