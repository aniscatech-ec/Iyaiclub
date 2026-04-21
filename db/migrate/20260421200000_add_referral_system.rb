class AddReferralSystem < ActiveRecord::Migration[8.0]
  def change
    # Código único de referido por usuario
    add_column :users, :referral_code, :string, limit: 12
    add_index  :users, :referral_code, unique: true

    # Configuración global de puntos por tipo de referido (gestionado por admins)
    create_table :referral_reward_configs do |t|
      t.string  :reward_type,   null: false  # "membership" | "ticket"
      t.integer :points,        null: false, default: 0
      t.text    :description
      t.timestamps
    end
    add_index :referral_reward_configs, :reward_type, unique: true

    # Registro de cada referido exitoso
    create_table :referrals do |t|
      t.references :referrer,  null: false, foreign_key: { to_table: :users }  # quien refirió
      t.references :referred,  null: true,  foreign_key: { to_table: :users }  # quien compró (nil si guest)
      t.string  :referred_email                                                  # para guests
      t.string  :reward_type,  null: false   # "membership" | "ticket"
      t.integer :points_awarded, null: false, default: 0
      t.string  :status,       null: false, default: "pendiente"  # pendiente | acreditado | cancelado
      t.integer :source_id                                         # subscription.id o ticket.id
      t.string  :source_type                                       # "Subscription" | "Ticket"
      t.timestamps
    end

    # Configs por defecto
    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO referral_reward_configs (reward_type, points, description, created_at, updated_at)
          VALUES
            ('membership', 200, 'Puntos por referir a alguien que compra una membresía', NOW(), NOW()),
            ('ticket',     100, 'Puntos por referir a alguien que compra un ticket de evento', NOW(), NOW())
        SQL
      end
    end
  end
end
