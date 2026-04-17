class AddBenefitFieldsToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :benefit_request, :boolean, default: false, null: false
    add_column :bookings, :benefit_type, :string
    add_column :bookings, :benefit_notes, :text
    add_column :bookings, :admin_notes, :text
    add_index  :bookings, :benefit_request
  end
end
