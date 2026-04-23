class CreateTourPackages < ActiveRecord::Migration[7.0]
  def change
    create_table :tour_packages do |t|
      t.references :travel_agency, null: false, foreign_key: true
      t.string :name
      t.string :duration
      t.text :itinerary
      t.decimal :price, precision: 10, scale: 2
      t.text :description

      t.timestamps
    end
  end
end
