class AddFeaturesTargetRoleToPlanPrices < ActiveRecord::Migration[8.0]
  def change
    add_column :plan_prices, :features, :json
    add_column :plan_prices, :target_role, :integer
  end
end
