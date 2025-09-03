class CreateVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :verifications do |t|
      t.string :identity_document
      t.string :property_document
      t.string :selfie
      t.references :establishment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
