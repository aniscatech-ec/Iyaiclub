class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :establishments, :category, if_not_exists: true
    add_index :establishments, :status, if_not_exists: true
    add_index :establishments, :city_id, if_not_exists: true
    add_index :establishments, :country_id, if_not_exists: true
    add_index :bookings, :status, if_not_exists: true
    add_index :bookings, :unit_id, if_not_exists: true
    add_index :units, :status, if_not_exists: true
    add_index :units, :establishment_id, if_not_exists: true
    add_index :galleries, :establishment_id, if_not_exists: true
    add_index :gallery_images, :gallery_id, if_not_exists: true
  end
end
