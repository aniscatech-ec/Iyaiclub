class RemoveIconFromAmenities < ActiveRecord::Migration[8.0]
  def change
    remove_column :amenities, :icon, :string
  end
end
