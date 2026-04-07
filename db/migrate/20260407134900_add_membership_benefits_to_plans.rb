class AddMembershipBenefitsToPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :plans, :plan_key, :string
    add_column :plans, :discount_percentage, :integer, default: 0
    add_column :plans, :fixed_discount, :integer, default: 0
    add_column :plans, :points_earned, :integer, default: 1
    add_column :plans, :dollars_per_point, :integer, default: 5
    add_column :plans, :pool_visits_per_year, :integer, default: 0
    add_column :plans, :pool_level, :integer, default: 0
    add_column :plans, :max_pool_guests, :integer, default: 0
    add_column :plans, :free_nights, :integer, default: 0
    add_column :plans, :free_days, :integer, default: 0
    add_column :plans, :includes_breakfast, :boolean, default: false
    add_column :plans, :includes_dinner, :boolean, default: false
    add_column :plans, :max_lodging_guests, :integer, default: 0
    add_column :plans, :events_access, :boolean, default: false
    add_column :plans, :is_student_plan, :boolean, default: false
    add_column :plans, :is_active, :boolean, default: true
    add_column :plans, :sort_order, :integer, default: 0

    add_index :plans, :plan_key, unique: true
    add_index :plans, :is_active
  end
end
