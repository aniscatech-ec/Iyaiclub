class AddIconAndTypeToAmenities < ActiveRecord::Migration[8.0]
  def change
    add_column :amenities, :icon, :string
    add_column :amenities, :type, :string
  end
end
