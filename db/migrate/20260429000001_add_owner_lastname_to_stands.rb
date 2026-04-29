class AddOwnerLastnameToStands < ActiveRecord::Migration[8.0]
  def change
    add_column :stands, :owner_lastname, :string
  end
end
