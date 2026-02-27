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

ActiveRecord::Schema[8.1].define(version: 2026_02_24_224958) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount_from", precision: 20, scale: 8, null: false
    t.decimal "amount_to", precision: 20, scale: 8, null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "from_currency", null: false
    t.decimal "rate", precision: 20, scale: 8, null: false
    t.string "status", default: "pending", null: false
    t.string "to_currency", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["status"], name: "index_transactions_on_status"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.index ["uuid"], name: "index_transactions_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  create_table "wallet_balances", force: :cascade do |t|
    t.decimal "amount", precision: 20, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "currency"], name: "index_wallet_balances_on_user_id_and_currency", unique: true
    t.index ["user_id"], name: "index_wallet_balances_on_user_id"
  end

  add_foreign_key "transactions", "users"
  add_foreign_key "wallet_balances", "users"
end
