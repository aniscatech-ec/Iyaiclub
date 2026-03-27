class AddWhatsappToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :whatsapp, :string, null: true
  end
end
