class RemoveEstablishmentIdFromUnits < ActiveRecord::Migration[8.0]
  def change
    remove_column :units, :establishment_id, :integer
  end
end
