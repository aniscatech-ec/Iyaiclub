class ChangeRefundPolicyToJsonInPricingPolicies < ActiveRecord::Migration[8.0]
  def change
    remove_column :pricing_policies, :refund_policy, :json
    add_column :pricing_policies, :refund_policy, :json
  end
end
