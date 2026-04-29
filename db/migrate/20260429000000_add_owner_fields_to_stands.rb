class AddOwnerFieldsToStands < ActiveRecord::Migration[8.0]
  def change
    add_column :stands, :owner_name, :string
    add_reference :stands, :country, foreign_key: true
    add_reference :stands, :city,    foreign_key: true
  end
end
