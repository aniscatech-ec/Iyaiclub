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

ActiveRecord::Schema[8.0].define(version: 2025_09_08_222715) do
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
  end

  create_table "bookings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.string "guest_name"
    t.string "guest_email"
    t.integer "guest_count"
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_price", precision: 10, scale: 2
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["city_id"], name: "index_establishments_on_city_id"
    t.index ["user_id"], name: "index_establishments_on_user_id"
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

  create_table "plan_prices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "plan_type"
    t.integer "duration", default: 0
    t.decimal "price", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "features"
    t.integer "target_role"
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
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "bed_configuration"
    t.index ["establishment_id"], name: "index_units_on_establishment_id"
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
    t.index ["city_id"], name: "index_users_on_city_id"
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "verifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_verifications_on_establishment_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "units"
  add_foreign_key "cities", "provinces"
  add_foreign_key "establishment_amenities", "amenities"
  add_foreign_key "establishment_amenities", "establishments"
  add_foreign_key "establishments", "cities"
  add_foreign_key "establishments", "users"
  add_foreign_key "galleries", "establishments"
  add_foreign_key "gallery_images", "galleries"
  add_foreign_key "legal_infos", "establishments"
  add_foreign_key "payment_methods", "establishments"
  add_foreign_key "pricing_policies", "establishments"
  add_foreign_key "provinces", "countries"
  add_foreign_key "unit_availabilities", "units"
  add_foreign_key "unit_prices", "units"
  add_foreign_key "units", "establishments"
  add_foreign_key "users", "cities"
  add_foreign_key "users", "countries"
  add_foreign_key "verifications", "establishments"
end
