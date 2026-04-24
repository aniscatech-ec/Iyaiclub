class AddUniqueIndexToReferralsSource < ActiveRecord::Migration[8.0]
  def change
    # Evita que el mismo source (Subscription o Ticket) genere más de un
    # referido acreditado, incluso ante reintentos o bugs en el flujo de pago.
    # Permite NULL en source_id para referidos sin source (caso legado).
    add_index :referrals, [:source_type, :source_id],
              unique: true,
              where: "source_id IS NOT NULL",
              name: "index_referrals_on_source_unique"
  end
end
