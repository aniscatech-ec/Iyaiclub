class CreateAdvertisements < ActiveRecord::Migration[8.0]
  def change
    create_table :advertisements do |t|
      t.string  :title,       null: false
      t.string  :description
      t.string  :tags
      t.string  :link_url
      t.boolean :active,      default: true, null: false
      t.integer :position,    default: 0,    null: false

      t.timestamps
    end
  end
end
