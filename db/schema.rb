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

ActiveRecord::Schema[8.1].define(version: 2026_10_20_105051) do
  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "iban", null: false
    t.string "account_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iban"], name: "index_accounts_on_iban", unique: true
  end

  create_table "balances", force: :cascade do |t|
    t.integer "account_id", null: false
    t.date "recorded_on", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "import_id"
    t.index ["account_id", "recorded_on"], name: "index_balances_on_account_id_and_recorded_on"
    t.index ["import_id"], name: "index_balances_on_import_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower(name)", name: "index_categories_on_lower_name_for_main", unique: true, where: "parent_id IS NULL"
    t.index "parent_id, lower(name)", name: "index_categories_on_parent_id_and_lower_name", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "counterparties", force: :cascade do |t|
    t.string "name", null: false
    t.string "iban"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "import_id"
    t.index ["iban"], name: "index_counterparties_on_iban", unique: true, where: "iban IS NOT NULL"
    t.index ["import_id"], name: "index_counterparties_on_import_id"
    t.index ["name"], name: "index_counterparties_on_name", unique: true, where: "iban IS NULL"
  end

  create_table "imports", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "filename", null: false
    t.integer "skipped_count", null: false
    t.boolean "created_account", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_imports_on_account_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "counterparty_id"
    t.date "booked_on", null: false
    t.date "value_on", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.text "reference"
    t.string "creditor_id"
    t.string "mandate_reference"
    t.string "customer_reference"
    t.text "raw_row", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "import_id"
    t.integer "category_id"
    t.index ["account_id", "booked_on"], name: "index_transactions_on_account_id_and_booked_on"
    t.index ["account_id", "raw_row"], name: "index_transactions_on_account_id_and_raw_row"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["counterparty_id"], name: "index_transactions_on_counterparty_id"
    t.index ["import_id"], name: "index_transactions_on_import_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "balances", "accounts"
  add_foreign_key "balances", "imports"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "counterparties", "imports", on_delete: :nullify
  add_foreign_key "imports", "accounts"
  add_foreign_key "sessions", "users"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "counterparties"
  add_foreign_key "transactions", "imports"
end
