class ExpandTourPackages < ActiveRecord::Migration[8.0]
  def change
    add_column :tour_packages, :package_type,      :string                          # aventura, cultural, relax, etc.
    add_column :tour_packages, :destination,        :string                          # destino principal
    add_column :tour_packages, :days,               :integer                         # número de días
    add_column :tour_packages, :nights,             :integer                         # número de noches
    add_column :tour_packages, :min_group,          :integer,  default: 1            # mínimo de personas
    add_column :tour_packages, :max_group,          :integer,  default: 15           # máximo de personas
    add_column :tour_packages, :difficulty,         :string                          # fácil, moderado, exigente
    add_column :tour_packages, :departure_point,    :string                          # punto de salida/encuentro
    add_column :tour_packages, :member_price,       :decimal,  precision: 10, scale: 2  # precio con membresía
    add_column :tour_packages, :includes,           :text                            # qué incluye
    add_column :tour_packages, :excludes,           :text                            # qué no incluye
    add_column :tour_packages, :next_departures,    :text                            # próximas salidas (texto libre)
    add_column :tour_packages, :season,             :string                          # temporada (todo el año, verano...)
    add_column :tour_packages, :includes_transport, :boolean,  default: false
    add_column :tour_packages, :includes_food,      :boolean,  default: false
    add_column :tour_packages, :includes_lodging,   :boolean,  default: false
    add_column :tour_packages, :includes_guide,     :boolean,  default: false
    add_column :tour_packages, :active,             :boolean,  default: true
  end
end
