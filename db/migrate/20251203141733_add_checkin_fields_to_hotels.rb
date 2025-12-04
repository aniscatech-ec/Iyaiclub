class AddCheckinFieldsToHotels < ActiveRecord::Migration[8.0]
  def change
    add_column :hotels, :check_in_time, :time
    add_column :hotels, :check_out_time, :time

    add_column :hotels, :early_check_in_from, :time
    add_column :hotels, :late_check_out_until, :time

    add_column :hotels, :reception_24h, :boolean, default: false
    add_column :hotels, :reception_open_time, :time
    add_column :hotels, :reception_close_time, :time
  end
end
