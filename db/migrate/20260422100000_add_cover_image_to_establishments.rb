class AddCoverImageToEstablishments < ActiveRecord::Migration[8.0]
  def change
    # Stores the ActiveStorage blob id of the chosen cover image (from images attachment)
    add_column :establishments, :cover_image_blob_id, :bigint, null: true
  end
end
