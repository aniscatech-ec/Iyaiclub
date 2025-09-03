class AddConfirmedToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :confirmed, :boolean
  end
end
