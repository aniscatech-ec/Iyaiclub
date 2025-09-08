class RemoveCountryFromEstablishments < ActiveRecord::Migration[8.0]
  def change
    remove_column :establishments, :country, :string
  end
end
