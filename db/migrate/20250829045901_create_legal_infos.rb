class CreateLegalInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :legal_infos do |t|
      t.string :business_name
      t.string :legal_representative
      t.string :document_type
      t.string :document_number
      t.string :contact_email
      t.string :contact_phone
      t.references :establishment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
