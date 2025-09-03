class CreatePricingPolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :pricing_policies do |t|
      t.references :establishment, null: false, foreign_key: true
      t.string :currency
      t.decimal :service_fee, precision: 5, scale: 2, default: 0.0
      t.integer :max_discount, default: 0
      t.text :refund_policy

      t.timestamps
    end
  end
end
