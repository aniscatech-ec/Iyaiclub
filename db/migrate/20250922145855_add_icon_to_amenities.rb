class AddIconToAmenities < ActiveRecord::Migration[8.0]
  def change
    add_column :amenities, :icon, :string
  end
end
