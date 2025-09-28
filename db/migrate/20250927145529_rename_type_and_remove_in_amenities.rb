class RenameTypeAndRemoveInAmenities < ActiveRecord::Migration[8.0]
    def change
      rename_column :amenities, :type, :applies_to
      remove_column :amenities, :icon, :string
    end
end
