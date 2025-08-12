class AddDetailsToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :address, :string
    add_column :establishments, :city, :string
    add_column :establishments, :country, :string
    add_column :establishments, :phone, :string
    add_column :establishments, :email, :string
    add_column :establishments, :website, :string
    add_column :establishments, :check_in_time, :string
    add_column :establishments, :check_out_time, :string
    add_column :establishments, :price_per_night, :decimal, precision: 8, scale: 2
    add_column :establishments, :total_rooms, :integer
    add_column :establishments, :available_rooms, :integer
    add_column :establishments, :latitude, :decimal, precision: 10, scale: 6
    add_column :establishments, :longitude, :decimal, precision: 10, scale: 6
    add_column :establishments, :rating, :decimal, precision: 2, scale: 1
    add_column :establishments, :policies, :text
  end
end
