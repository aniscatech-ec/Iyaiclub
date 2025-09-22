class CreateHotels < ActiveRecord::Migration[8.0]
  def change
    create_table :hotels do |t|
      t.references :establishment, null: false, foreign_key: true
      t.integer :stars
      t.string :hotel_type

      t.timestamps
    end
  end
end
