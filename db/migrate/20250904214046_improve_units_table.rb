class ImproveUnitsTable < ActiveRecord::Migration[8.0]
  def change
    change_table :units do |t|
      t.remove :beds
      t.remove :seasonal_prices
      t.remove :available

      t.json :bed_configuration
    end
  end
end
