# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_26_024744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.datetime "date", null: false
    t.integer "directive", default: 0, null: false
    t.string "name", null: false
    t.string "currencies", default: [], null: false, array: true
    t.string "booking"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["currencies"], name: "index_accounts_on_currencies", using: :gin
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "date", null: false
    t.integer "directive", default: 0, null: false
    t.text "arguments"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "postings", force: :cascade do |t|
    t.string "flag"
    t.bigint "account_id", null: false
    t.text "arguments", null: false
    t.text "comment"
    t.bigint "entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_postings_on_account_id"
    t.index ["entry_id"], name: "index_postings_on_entry_id"
  end

  add_foreign_key "postings", "accounts", on_delete: :cascade
  add_foreign_key "postings", "entries", on_delete: :cascade
end
