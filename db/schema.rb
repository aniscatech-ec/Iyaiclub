# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_04_15_013122) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "amenities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "establishment_type"
  end

  create_table "booking_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.bigint "user_id"
    t.string "source"
    t.string "status"
    t.string "ip_address"
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_booking_requests_on_establishment_id"
    t.index ["user_id"], name: "index_booking_requests_on_user_id"
  end

  create_table "bookings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id"
    t.string "guest_name"
    t.string "guest_email"
    t.integer "guest_count"
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_price", precision: 10, scale: 2
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "room_id"
    t.index ["room_id"], name: "index_bookings_on_room_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["unit_id"], name: "index_bookings_on_unit_id"
  end

  create_table "cities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "province_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["province_id"], name: "index_cities_on_province_id"
  end

  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "assigned_to_id"
    t.string "destination", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "guests_count", null: false
    t.decimal "estimated_budget", precision: 10, scale: 2
    t.integer "experience_type", default: 0, null: false
    t.text "interests"
    t.text "preferences"
    t.text "comments"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_custom_requests_on_assigned_to_id"
    t.index ["experience_type"], name: "index_custom_requests_on_experience_type"
    t.index ["status"], name: "index_custom_requests_on_status"
    t.index ["user_id"], name: "index_custom_requests_on_user_id"
  end

  create_table "establishment_amenities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.bigint "amenity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_establishment_amenities_on_amenity_id"
    t.index ["establishment_id"], name: "index_establishment_amenities_on_establishment_id"
  end

  create_table "establishments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "category"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "phone"
    t.string "email"
    t.string "website"
    t.time "check_in_time"
    t.time "check_out_time"
    t.decimal "price_per_night", precision: 8, scale: 2
    t.integer "total_rooms"
    t.integer "available_rooms"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.decimal "rating", precision: 2, scale: 1
    t.json "policies"
    t.bigint "city_id"
    t.text "short_description"
    t.text "long_description"
    t.integer "service_fee"
    t.integer "max_discount"
    t.integer "province_id"
    t.integer "country_id"
    t.text "arrival_instructions"
    t.boolean "confirmed"
    t.json "refund_policy"
    t.string "video_url"
    t.string "whatsapp"
    t.time "opening_time"
    t.time "closing_time"
    t.integer "status", default: 0, null: false
    t.integer "tipo_gestion_reserva", default: 0, null: false
    t.index ["category"], name: "index_establishments_on_category"
    t.index ["city_id"], name: "index_establishments_on_city_id"
    t.index ["country_id"], name: "index_establishments_on_country_id"
    t.index ["status"], name: "index_establishments_on_status"
    t.index ["tipo_gestion_reserva"], name: "index_establishments_on_tipo_gestion_reserva"
    t.index ["user_id"], name: "index_establishments_on_user_id"
  end

  create_table "event_vendedores", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "user_id"], name: "index_event_vendedores_on_event_id_and_user_id", unique: true
    t.index ["event_id"], name: "index_event_vendedores_on_event_id"
    t.index ["user_id"], name: "index_event_vendedores_on_user_id"
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "event_date"
    t.string "location"
    t.string "maps_url"
    t.decimal "ticket_price", precision: 10, scale: 2
    t.integer "total_tickets"
    t.integer "available_tickets"
    t.string "image"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_date"], name: "index_events_on_event_date"
    t.index ["status"], name: "index_events_on_status"
  end

  create_table "galleries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_galleries_on_establishment_id"
  end

  create_table "gallery_images", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "is_cover"
    t.string "video_url"
    t.bigint "gallery_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gallery_id"], name: "index_gallery_images_on_gallery_id"
  end

  create_table "getaways", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "subcategory"
    t.decimal "entry_price", precision: 10, scale: 2
    t.text "recommendations"
    t.text "rules"
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_getaways_on_establishment_id"
  end

  create_table "hotels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.integer "stars"
    t.string "hotel_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "check_in_time"
    t.time "check_out_time"
    t.time "early_check_in_from"
    t.time "late_check_out_until"
    t.boolean "reception_24h", default: false
    t.time "reception_open_time"
    t.time "reception_close_time"
    t.integer "total_rooms"
    t.integer "available_rooms"
    t.integer "max_guests"
    t.index ["establishment_id"], name: "index_hotels_on_establishment_id"
  end

  create_table "legal_infos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "business_name"
    t.string "legal_representative"
    t.string "document_type"
    t.string "document_number"
    t.string "contact_email"
    t.string "contact_phone"
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_legal_infos_on_establishment_id"
  end

  create_table "lodgings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "lodging_type", null: false
    t.decimal "price_per_night", precision: 10, scale: 2, null: false
    t.time "check_in_time"
    t.time "check_out_time"
    t.text "rules"
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_lodgings_on_establishment_id"
  end

  create_table "menu_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.string "photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_menu_items_on_menu_id"
  end

  create_table "menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "restaurant_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_menus_on_restaurant_id"
  end

  create_table "payment_methods", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "method_type"
    t.string "bank_name"
    t.string "account_type"
    t.string "account_number"
    t.string "account_holder"
    t.string "tax_id"
    t.string "preferred_currency"
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_payment_methods_on_establishment_id"
  end

  create_table "payment_receipts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.integer "status"
    t.bigint "user_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_payment_receipts_on_subscription_id"
    t.index ["user_id"], name: "index_payment_receipts_on_user_id"
  end

  create_table "payphone_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "payable_type"
    t.bigint "payable_id"
    t.bigint "user_id", null: false
    t.bigint "transaction_id"
    t.string "client_transaction_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "USD"
    t.integer "status", default: 0, null: false
    t.integer "status_code"
    t.string "authorization_code"
    t.string "card_brand"
    t.string "card_last_digits"
    t.string "phone_number"
    t.string "email"
    t.json "response_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "metadata"
    t.index ["client_transaction_id"], name: "index_payphone_transactions_on_client_transaction_id", unique: true
    t.index ["payable_type", "payable_id"], name: "index_payphone_transactions_on_payable"
    t.index ["status"], name: "index_payphone_transactions_on_status"
    t.index ["transaction_id"], name: "index_payphone_transactions_on_transaction_id"
    t.index ["user_id"], name: "index_payphone_transactions_on_user_id"
  end

  create_table "plan_prices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "plan_type"
    t.integer "duration", default: 0
    t.decimal "price", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "features"
    t.integer "target_role"
    t.bigint "plan_id", null: false
    t.index ["plan_id"], name: "index_plan_prices_on_plan_id"
  end

  create_table "plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.json "features"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plan_key"
    t.integer "discount_percentage", default: 0
    t.integer "fixed_discount", default: 0
    t.integer "points_earned", default: 1
    t.integer "dollars_per_point", default: 5
    t.integer "pool_visits_per_year", default: 0
    t.integer "pool_level", default: 0
    t.integer "max_pool_guests", default: 0
    t.integer "free_nights", default: 0
    t.integer "free_days", default: 0
    t.boolean "includes_breakfast", default: false
    t.boolean "includes_dinner", default: false
    t.integer "max_lodging_guests", default: 0
    t.boolean "events_access", default: false
    t.boolean "is_student_plan", default: false
    t.boolean "is_active", default: true
    t.integer "sort_order", default: 0
    t.index ["is_active"], name: "index_plans_on_is_active"
    t.index ["plan_key"], name: "index_plans_on_plan_key", unique: true
  end

  create_table "pricing_policies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.string "currency"
    t.decimal "service_fee", precision: 5, scale: 2, default: "0.0"
    t.integer "max_discount", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "refund_policy"
    t.index ["establishment_id"], name: "index_pricing_policies_on_establishment_id"
  end

  create_table "provinces", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id", null: false
    t.index ["country_id"], name: "index_provinces_on_country_id"
  end

  create_table "raffles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.integer "winning_number"
    t.string "prize"
    t.datetime "draw_date"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_raffles_on_event_id"
    t.index ["status"], name: "index_raffles_on_status"
  end

  create_table "redemptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "reward_id", null: false
    t.integer "points_used", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reward_id"], name: "index_redemptions_on_reward_id"
    t.index ["status"], name: "index_redemptions_on_status"
    t.index ["user_id"], name: "index_redemptions_on_user_id"
  end

  create_table "reservations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.bigint "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_reservations_on_unit_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "restaurant_hours", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "restaurant_id", null: false
    t.integer "day_of_week"
    t.time "open_time"
    t.time "close_time"
    t.boolean "closed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_restaurant_hours_on_restaurant_id"
  end

  create_table "restaurant_tables", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "restaurant_id", null: false
    t.string "name", null: false
    t.string "table_type"
    t.integer "seats", null: false
    t.integer "quantity", default: 1
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_restaurant_tables_on_restaurant_id"
  end

  create_table "restaurants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.string "cuisine_type"
    t.string "restaurant_type"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_tables"
    t.integer "seats_per_table"
    t.integer "available_tables"
    t.integer "total_capacity"
    t.index ["establishment_id"], name: "index_restaurants_on_establishment_id"
  end

  create_table "rewards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "points_required", null: false
    t.bigint "establishment_id"
    t.integer "category", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_rewards_on_active"
    t.index ["category"], name: "index_rewards_on_category"
    t.index ["establishment_id"], name: "index_rewards_on_establishment_id"
  end

  create_table "room_amenities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "amenity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_room_amenities_on_amenity_id"
    t.index ["room_id", "amenity_id"], name: "index_room_amenities_on_room_id_and_amenity_id", unique: true
    t.index ["room_id"], name: "index_room_amenities_on_room_id"
  end

  create_table "room_beds", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "bed_type", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_room_beds_on_room_id"
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "hotel_id"
    t.string "name", null: false
    t.string "room_type"
    t.string "bed_type"
    t.integer "num_beds"
    t.decimal "price_per_night", precision: 10, scale: 2
    t.integer "guest_capacity"
    t.text "description"
    t.integer "quantity", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "temporary_lodging_id"
    t.index ["hotel_id"], name: "index_rooms_on_hotel_id"
    t.index ["temporary_lodging_id"], name: "index_rooms_on_temporary_lodging_id"
  end

  create_table "subscriptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "plan_type"
    t.integer "status", default: 0
    t.date "start_date"
    t.date "end_date"
    t.integer "payment_method"
    t.text "payment_instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subscribable_type", null: false
    t.bigint "subscribable_id", null: false
    t.index ["subscribable_type", "subscribable_id"], name: "index_subscriptions_on_subscribable"
  end

  create_table "temporary_lodgings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.string "lodging_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_guests"
    t.integer "total_rooms"
    t.integer "total_bathrooms"
    t.index ["establishment_id"], name: "index_temporary_lodgings_on_establishment_id"
    t.index ["lodging_type"], name: "index_temporary_lodgings_on_lodging_type"
  end

  create_table "tickets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "payphone_transaction_id"
    t.string "ticket_code", null: false
    t.integer "raffle_number", null: false
    t.string "guest_name", null: false
    t.string "guest_email"
    t.string "guest_phone"
    t.string "event_name", null: false
    t.date "event_date"
    t.string "event_location"
    t.decimal "unit_price", precision: 10, scale: 2
    t.decimal "total_price", precision: 10, scale: 2
    t.integer "status", default: 0, null: false
    t.datetime "used_at"
    t.text "qr_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id"
    t.integer "payment_method", default: 0, null: false
    t.bigint "vendedor_id"
    t.datetime "reserved_at"
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["event_name"], name: "index_tickets_on_event_name"
    t.index ["payment_method"], name: "index_tickets_on_payment_method"
    t.index ["payphone_transaction_id"], name: "index_tickets_on_payphone_transaction_id"
    t.index ["raffle_number"], name: "index_tickets_on_raffle_number", unique: true
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["ticket_code"], name: "index_tickets_on_ticket_code", unique: true
    t.index ["user_id"], name: "index_tickets_on_user_id"
    t.index ["vendedor_id"], name: "index_tickets_on_vendedor_id"
  end

  create_table "transports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.string "transport_type", null: false
    t.string "subcategory", null: false
    t.integer "capacity"
    t.text "service_description"
    t.string "price_range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_vehicles"
    t.integer "available_vehicles"
    t.text "routes"
    t.string "service_frequency"
    t.string "operating_area"
    t.index ["establishment_id"], name: "index_transports_on_establishment_id"
    t.index ["subcategory"], name: "index_transports_on_subcategory"
    t.index ["transport_type"], name: "index_transports_on_transport_type"
  end

  create_table "unit_availabilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.date "date"
    t.boolean "available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_unit_availabilities_on_unit_id"
  end

  create_table "unit_prices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.string "season"
    t.decimal "price", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_unit_prices_on_unit_id"
  end

  create_table "units", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "unit_type"
    t.integer "capacity"
    t.decimal "base_price", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "bed_configuration"
    t.bigint "establishment_id", null: false
    t.decimal "price_per_person", precision: 10
    t.integer "status"
    t.index ["establishment_id"], name: "index_units_on_establishment_id"
    t.index ["establishment_id"], name: "index_units_on_hotel_id"
    t.index ["status"], name: "index_units_on_status"
  end

  create_table "user_points", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "establishment_id", null: false
    t.integer "points_earned", default: 0, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_user_points_on_establishment_id"
    t.index ["user_id", "created_at"], name: "index_user_points_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_user_points_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "phone"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id", null: false
    t.bigint "city_id", null: false
    t.date "birth_date"
    t.boolean "terms_accepted"
    t.boolean "marketing_consent"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["city_id"], name: "index_users_on_city_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "transport_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "price_per_day", precision: 8, scale: 2
    t.text "conditions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transport_id"], name: "index_vehicles_on_transport_id"
  end

  create_table "verifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_verifications_on_establishment_id"
  end

  create_table "visits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "establishment_id", null: false
    t.datetime "visited_at", null: false
    t.integer "source", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_visits_on_establishment_id"
    t.index ["user_id", "establishment_id"], name: "index_visits_on_user_id_and_establishment_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
    t.index ["visited_at"], name: "index_visits_on_visited_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_requests", "establishments"
  add_foreign_key "booking_requests", "users"
  add_foreign_key "bookings", "rooms"
  add_foreign_key "bookings", "units"
  add_foreign_key "cities", "provinces"
  add_foreign_key "custom_requests", "users"
  add_foreign_key "custom_requests", "users", column: "assigned_to_id"
  add_foreign_key "establishment_amenities", "amenities"
  add_foreign_key "establishment_amenities", "establishments"
  add_foreign_key "establishments", "cities"
  add_foreign_key "establishments", "users"
  add_foreign_key "event_vendedores", "events"
  add_foreign_key "event_vendedores", "users"
  add_foreign_key "galleries", "establishments"
  add_foreign_key "gallery_images", "galleries"
  add_foreign_key "getaways", "establishments"
  add_foreign_key "hotels", "establishments"
  add_foreign_key "legal_infos", "establishments"
  add_foreign_key "lodgings", "establishments"
  add_foreign_key "menu_items", "menus"
  add_foreign_key "menus", "restaurants"
  add_foreign_key "payment_methods", "establishments"
  add_foreign_key "payment_receipts", "subscriptions"
  add_foreign_key "payment_receipts", "users"
  add_foreign_key "payphone_transactions", "users"
  add_foreign_key "plan_prices", "plans"
  add_foreign_key "pricing_policies", "establishments"
  add_foreign_key "provinces", "countries"
  add_foreign_key "raffles", "events"
  add_foreign_key "redemptions", "rewards"
  add_foreign_key "redemptions", "users"
  add_foreign_key "reservations", "units"
  add_foreign_key "reservations", "users"
  add_foreign_key "restaurant_hours", "restaurants"
  add_foreign_key "restaurant_tables", "restaurants"
  add_foreign_key "restaurants", "establishments"
  add_foreign_key "rewards", "establishments"
  add_foreign_key "room_amenities", "amenities"
  add_foreign_key "room_amenities", "rooms"
  add_foreign_key "room_beds", "rooms"
  add_foreign_key "rooms", "hotels"
  add_foreign_key "rooms", "temporary_lodgings"
  add_foreign_key "temporary_lodgings", "establishments"
  add_foreign_key "tickets", "events"
  add_foreign_key "tickets", "payphone_transactions"
  add_foreign_key "tickets", "users"
  add_foreign_key "tickets", "users", column: "vendedor_id"
  add_foreign_key "transports", "establishments"
  add_foreign_key "unit_availabilities", "units"
  add_foreign_key "unit_prices", "units"
  add_foreign_key "units", "hotels", column: "establishment_id"
  add_foreign_key "user_points", "establishments"
  add_foreign_key "user_points", "users"
  add_foreign_key "users", "cities"
  add_foreign_key "users", "countries"
  add_foreign_key "vehicles", "transports"
  add_foreign_key "verifications", "establishments"
  add_foreign_key "visits", "establishments"
  add_foreign_key "visits", "users"
end
