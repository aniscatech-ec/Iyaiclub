class RenameCategoryToRestaurantTypeInRestaurants < ActiveRecord::Migration[8.0]
  def change
    rename_column :restaurants, :category, :restaurant_type
  end
end
