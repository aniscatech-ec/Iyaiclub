class CreateMenuOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_options do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.string :name
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
