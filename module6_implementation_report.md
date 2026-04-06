# Reporte de Implementación: Módulo 6 (Hospedajes / Lodgings)

## 1. Resumen de Implementación
El Módulo 6 "Lodgings" ha sido implementado utilizando la arquitectura limpia en que se basó el modelo previo (Getaways). Permite que los Establishments especifiquen unidades de hospedaje con capacidades transaccionales integradas, protegiendo los parámetros mediante strong parameters y acoplando una interfaz unificada mediante cards de Bootstrap.

## 2. Archivos creados
* `app/models/lodging.rb`
* `app/controllers/lodgings_controller.rb`
* `app/views/lodgings/index.html.erb`
* `app/views/lodgings/show.html.erb`
* `app/views/lodgings/new.html.erb`
* `app/views/lodgings/edit.html.erb`
* `app/views/lodgings/_form.html.erb`

## 3. Migraciones creadas
* `db/migrate/20260406015400_create_lodgings.rb`
  * Tabla generada que incluye:
    * `lodging_type` (entero, enum)
    * `price_per_night` (decimal, null falso)
    * `check_in_time` (time)
    * `check_out_time` (time)
    * `rules` (text)
    * `establishment_id` (foreign key)

## 4. Asociaciones
- En `Lodging`: `belongs_to :establishment`
- En `Establishment`: `has_many :lodgings, dependent: :destroy`

## 5. Rutas agregadas
Ruteo con shallow mode integrado en `config/routes.rb`:
```ruby
resources :establishments do
  resources :lodgings, shallow: true
end
```

## 6. Vistas implementadas y Mejoras Integradas
- Las 5 vistas CRUD construyen una interacción de tarjeta azul/info que las distingue del diseño verde u orgánico de Getaways para denotar visualmente su pertenencia al rubro Hotelero.
- En `establishments/show.html.erb` se añadió la **Sección 11**: "Hospedajes Disponibles (Lodgings)", la cual levanta en memoria temporal una muestra reducida de hasta 3 tarjetas con información ágil del hospedaje y botones directos, evitando la fricción de navegación.

## 7. Validaciones del Modelo
El modelo ahora soporta validaciones obligatorias:
```ruby
validates :lodging_type, presence: true
validates :price_per_night, presence: true, numericality: { greater_than: 0 }
```

NOTA: Se sugiere la acción `rails db:migrate` en su entorno físico antes de accionar la lógica.
