class CreatePlanVendedores < ActiveRecord::Migration[8.0]
  def change
    create_table :plan_vendedores do |t|
      t.references :plan,     null: false, foreign_key: true
      t.references :vendedor, null: false, foreign_key: { to_table: :users }
      t.boolean    :active,   default: true, null: false
      t.timestamps
    end
    add_index :plan_vendedores, [:plan_id, :vendedor_id], unique: true
  end
end
