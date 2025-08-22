class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :establishment, null: false, foreign_key: true
      t.integer :plan_type, default: 0 # gratis / basico / vip
      t.integer :duration, default: 0 # gratis / mensual / semestral / anual
      t.integer :status, default: 0   # gratis / pendiente / aprobada / vencida
      t.date :start_date
      t.date :end_date
      t.decimal :amount, precision: 10, scale: 2
      t.integer :payment_method, default: 0 # transferencia / tarjeta / efectivo
      t.text :payment_instructions

      t.timestamps
    end
  end
end
