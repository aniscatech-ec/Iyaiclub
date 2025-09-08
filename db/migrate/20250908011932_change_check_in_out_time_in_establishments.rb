class ChangeCheckInOutTimeInEstablishments < ActiveRecord::Migration[8.0]
  def change
    change_column :establishments, :check_in_time, :time
    change_column :establishments, :check_out_time, :time
  end
end
