class CreateRoomBeds < ActiveRecord::Migration[8.0]
  def change
    create_table :room_beds do |t|
      t.references :room, null: false, foreign_key: true
      t.string :bed_type, null: false
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
