class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.references :hotel, null: false, foreign_key: true
      t.string :name, null: false
      t.string :room_type
      t.string :bed_type
      t.integer :num_beds
      t.decimal :price_per_night, precision: 10, scale: 2
      t.integer :guest_capacity
      t.text :description
      t.integer :quantity, default: 1

      t.timestamps
    end
  end
end
