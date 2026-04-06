class CreateLodgings < ActiveRecord::Migration[8.0]
  def change
    create_table :lodgings do |t|
      t.integer :lodging_type, null: false
      t.decimal :price_per_night, precision: 10, scale: 2, null: false
      t.time :check_in_time
      t.time :check_out_time
      t.text :rules
      t.references :establishment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
