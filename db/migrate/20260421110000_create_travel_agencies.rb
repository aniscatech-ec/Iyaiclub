class CreateTravelAgencies < ActiveRecord::Migration[7.0]
  def change
    create_table :travel_agencies do |t|
      t.references :establishment, null: false, foreign_key: true
      t.integer :subcategory, default: 0

      t.timestamps
    end
  end
end
