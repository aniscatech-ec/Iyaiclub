class AddRucAndEmailToStands < ActiveRecord::Migration[8.0]
  def change
    add_column :stands, :ruc,   :string
    add_column :stands, :email, :string

    add_index :stands, :ruc,   unique: true
    add_index :stands, :email, unique: true
  end
end
