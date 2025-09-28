class RenameAppliesToInAmenities < ActiveRecord::Migration[8.0]
  def change
    rename_column :amenities, :applies_to, :category

  end
end
