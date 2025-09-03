class AddLocationFieldsToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :province_id, :integer
    add_column :establishments, :country_id, :integer
    add_column :establishments, :arrival_instructions, :text
  end
end
