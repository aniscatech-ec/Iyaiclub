class CreateMenuCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_categories do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
