class AddStatusToUnits < ActiveRecord::Migration[8.0]
  def change
    add_column :units, :status, :integer
  end
end
