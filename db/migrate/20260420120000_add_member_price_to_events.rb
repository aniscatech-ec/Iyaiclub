class AddMemberPriceToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :member_price,     :decimal, precision: 10, scale: 2
    add_column :events, :non_member_price, :decimal, precision: 10, scale: 2

    # Migrar datos existentes: el precio actual pasa a ser ambos precios
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE events
          SET member_price     = ticket_price,
              non_member_price = ticket_price
          WHERE ticket_price IS NOT NULL
        SQL
      end
    end
  end
end
