class AddExtraFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :country, null: false, foreign_key: true
    add_reference :users, :city, null: false, foreign_key: true
    add_column :users, :birth_date, :date
    add_column :users, :terms_accepted, :boolean
    add_column :users, :marketing_consent, :boolean
  end
end
