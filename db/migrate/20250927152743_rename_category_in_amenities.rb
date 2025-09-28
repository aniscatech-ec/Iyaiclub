class RenameCategoryInAmenities < ActiveRecord::Migration[8.0]
  def change
    rename_column :amenities, :category, :establishment_type
  end
end
