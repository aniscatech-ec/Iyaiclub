class AddVideoUrlToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :video_url, :string
  end
end
