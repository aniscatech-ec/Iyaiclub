class AddFieldsToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :short_description, :text
    add_column :establishments, :long_description, :text
    add_column :establishments, :service_fee, :integer
    add_column :establishments, :max_discount, :integer
    add_column :establishments, :refund_policy, :text
  end
end
