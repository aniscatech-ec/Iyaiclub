class CreateGetaways < ActiveRecord::Migration[8.0]
  def change
    create_table :getaways do |t|
      t.integer :subcategory
      t.decimal :entry_price, precision: 10, scale: 2
      t.text :recommendations
      t.text :rules
      t.references :establishment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
