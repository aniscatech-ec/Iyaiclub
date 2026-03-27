class AddOperatingHoursToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :opening_time, :time, null: true
    add_column :establishments, :closing_time, :time, null: true
  end
end
