class CreatePromotions < ActiveRecord::Migration[8.0]
  def change
    create_table :promotions do |t|
      t.references :establishment, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :discount_percentage, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end
  end
end
