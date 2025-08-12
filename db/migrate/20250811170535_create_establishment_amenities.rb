class CreateEstablishmentAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :establishment_amenities do |t|
      t.references :establishment, null: false, foreign_key: true
      t.references :amenity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
