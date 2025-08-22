class ChangePaymentMethodAndPlanTypeNullableInSubscriptions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subscriptions, :payment_method, true
    change_column_default :subscriptions, :payment_method, nil

    change_column_null :subscriptions, :plan_type, true
    change_column_default :subscriptions, :plan_type, nil
  end
end
