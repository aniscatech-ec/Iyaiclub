class AddVendorCodeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :vendor_code, :string
    add_index  :users, :vendor_code, unique: true
  end
end
