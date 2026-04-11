# Module 8: Bookings / Reservations Implementation Report

## Architecture Overview
Instead of creating a separate `Reservation` module or completely replacing the `Booking` schema, we followed a polymorphic approach to extend the **existing** `Booking` model to handle multiple resources:
- `Unit` (original implementation, Hotels)
- `Experience`
- `Lodging`
- `Getaway`

## 1. Migration File
A database migration was manually created (`db/migrate/20260411183919_make_bookings_polymorphic.rb`) which avoids breaking changes:
- Renamed `unit_id` to `bookable_id`.
- Added `bookable_type` string column.
- Added a backfill SQL query to set all previous bookings with `bookable_type = 'Unit'` to keep backward compatibility before marking it as NOT NULL.
- Re-adjusted indexes to be polymorphic (`[bookable_type, bookable_id]`).
- Added a `user_id` as a foreign key to allow natively attributing bookings to specific `User` records going forward.

## 2. Model Updates

### Booking Model (`app/models/booking.rb`)
- Implemented `belongs_to :bookable, polymorphic: true`.
- Retained a constrained `belongs_to :unit` with a custom scope (`-> { where(...) }`) and explicit `foreign_key: 'bookable_id'` so existing code that references `@booking.unit` continues to seamlessly work for hotel units.
- Modified validations conditionally:
  - Bookings for `Unit` continue to enforce `guest_name`, `guest_email`, `end_date`, availability, etc.
  - Polymorphic relations (`Experience`, `Lodging`, `Getaway`) trigger generic validations (`start_date`, `guest_count`).
- Use `alias_attribute` for bridging terminology differences seamlessly (`date` -> `start_date`, `guests` -> `guest_count`).

### Related Models
- `Experience`, `Lodging`, `Getaway`, and `Unit` models are now properly equipped with `has_many :bookings, as: :bookable, dependent: :destroy`.
- `User` was updated with a native ActiveRecord `has_many :bookings, dependent: :destroy`, replacing the previous manual query method.

## 3. Controller Actions (`app/controllers/bookings_controller.rb`)
- Rewrote the controller to natively look for polymorphism. 
- Actions are protected and use a `set_parent` strategy based on URL prefixes (e.g., `params[:experience_id]` vs `params[:lodging_id]`, etc.).
- Keeps fallback logic when dealing with `hotel_id` params for legacy `Hotel` contexts.
- Added native support for responding with `format.json` payloads automatically across all routes, making it ready as an API.

## 4. Routes Configuration (`config/routes.rb`)
Added cleanly isolated nested structures for bookings:
```ruby
  resources :getaways, only: [:index, :show] do
    resources :bookings, only: [:index, :new, :create, :show, :update, :destroy]
  end
  
  resources :experiences, only: [] do
    resources :bookings, only: [:index, :new, :create, :show, :update, :destroy]
  end

  resources :lodgings, only: [] do
    resources :bookings, only: [:index, :new, :create, :show, :update, :destroy]
  end

  # Generic user bookings list
  resources :bookings, only: [:index]
```

## 5. Example JSON Response
An example of responding from `POST /experiences/:experience_id/bookings` with `Accept: application/json` or querying via `GET /bookings/:id.json`:

```json
{
  "id": 105,
  "user_id": 4,
  "bookable_type": "Experience",
  "bookable_id": 12,
  "start_date": "2026-05-15",
  "end_date": null,
  "guest_count": 2,
  "status": "pendiente",
  "guest_name": null,
  "guest_email": null,
  "created_at": "2026-04-11T13:42:15.000Z",
  "updated_at": "2026-04-11T13:42:15.000Z",
  "date": "2026-05-15",
  "guests": 2
}
```
*(Notice how the aliased attributes `date` and `guests` represent `start_date` and `guest_count` natively.)*

## Notes
- To resolve pending migrations successfully, please run `bundle install` and fix the `nokogiri` gem compatibility issues present in your local environment, followed by `bin/rails db:migrate`.
