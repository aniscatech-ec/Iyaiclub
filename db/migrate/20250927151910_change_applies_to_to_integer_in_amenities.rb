class ChangeAppliesToToIntegerInAmenities < ActiveRecord::Migration[8.0]
  def change
    change_column :amenities, :applies_to, :integer
  end
end
