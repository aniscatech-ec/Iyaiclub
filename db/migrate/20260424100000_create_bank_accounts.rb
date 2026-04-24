class CreateBankAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.string  :institution,    null: false
      t.string  :account_type,   null: false  # ahorros / corriente
      t.string  :account_number, null: false
      t.string  :owner_name,     null: false
      t.string  :identifier,     null: false  # número de cédula o RUC
      t.string  :identifier_type, null: false, default: "cedula"  # cedula / ruc
      t.boolean :active,         null: false, default: true
      t.text    :notes

      t.timestamps
    end
  end
end
