class AddCapacityFieldsToTransports < ActiveRecord::Migration[7.1]
  def change
    add_column :transports, :total_vehicles, :integer
    add_column :transports, :available_vehicles, :integer
    add_column :transports, :routes, :text
    add_column :transports, :service_frequency, :string
    add_column :transports, :operating_area, :string
  end
end
