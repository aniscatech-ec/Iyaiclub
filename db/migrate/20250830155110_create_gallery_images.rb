class CreateGalleryImages < ActiveRecord::Migration[8.0]
  def change
    create_table :gallery_images do |t|
      t.boolean :is_cover
      t.string :video_url
      t.references :gallery, null: false, foreign_key: true

      t.timestamps
    end
  end
end
