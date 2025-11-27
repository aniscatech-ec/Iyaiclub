class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :menu_category, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.string :image_url
      t.boolean :is_vegan
      t.boolean :is_vegetarian
      t.boolean :is_gluten_free
      t.boolean :is_special
      t.integer :spicy_level
      t.integer :position

      t.timestamps
    end
  end
end
