class AddPricePerPersonToUnits < ActiveRecord::Migration[8.0]
  def change
    add_column :units, :price_per_person, :decimal
  end
end
