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

ActiveRecord::Schema[8.1].define(version: 2026_04_30_071343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "charities", force: :cascade do |t|
    t.boolean "approved", default: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "org_name", null: false
    t.string "prefecture"
    t.string "region", null: false
    t.text "shipping_address"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_charities_on_user_id"
  end

  create_table "donors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "donor_type"
    t.string "prefecture"
    t.string "region"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_donors_on_user_id"
  end

  create_table "offers", force: :cascade do |t|
    t.date "can_ship_by"
    t.string "condition", null: false
    t.datetime "created_at", null: false
    t.bigint "donor_id", null: false
    t.text "message"
    t.integer "quantity_offered", null: false
    t.bigint "request_id", null: false
    t.string "status", default: "submitted", null: false
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.index ["donor_id"], name: "index_offers_on_donor_id"
    t.index ["request_id"], name: "index_offers_on_request_id"
  end

  create_table "requests", force: :cascade do |t|
    t.string "category", null: false
    t.bigint "charity_id", null: false
    t.string "condition", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "prefecture"
    t.integer "quantity_needed", null: false
    t.integer "quantity_remaining", null: false
    t.string "region", null: false
    t.string "status", default: "inactive", null: false
    t.string "title", null: false
    t.string "units", null: false
    t.datetime "updated_at", null: false
    t.string "urgency", null: false
    t.index ["charity_id"], name: "index_requests_on_charity_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "charities", "users"
  add_foreign_key "donors", "users"
  add_foreign_key "offers", "donors"
  add_foreign_key "offers", "requests"
  add_foreign_key "requests", "charities"
end
