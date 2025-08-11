class CreateEstablishments < ActiveRecord::Migration[8.0]
  def change
    create_table :establishments do |t|
      t.string :name
      t.text :description
      t.integer :category
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
