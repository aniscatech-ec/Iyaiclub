class ChangePoliciesToJsonInEstablishments < ActiveRecord::Migration[8.0]
  def change
    change_column :establishments, :policies, :json
  end
end
