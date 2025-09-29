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

ActiveRecord::Schema[8.0].define(version: 2025_09_29_164608) do
  create_table "build_items", force: :cascade do |t|
    t.integer "build_id", null: false
    t.integer "part_id", null: false
    t.integer "quantity"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["build_id"], name: "index_build_items_on_build_id"
    t.index ["part_id"], name: "index_build_items_on_part_id"
  end

  create_table "builds", force: :cascade do |t|
    t.string "name"
    t.integer "total_wattage"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_builds_on_user_id"
  end

  create_table "parts", force: :cascade do |t|
    t.string "type"
    t.string "brand"
    t.string "name"
    t.string "model_number"
    t.integer "price_cents"
    t.integer "wattage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cpu_cores"
    t.integer "cpu_threads"
    t.decimal "cpu_base_ghz", precision: 4, scale: 2
    t.decimal "cpu_boost_ghz", precision: 4, scale: 2
    t.string "cpu_socket"
    t.integer "cpu_tdp_w"
    t.integer "cpu_cache_mb"
    t.string "cpu_igpu"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "build_items", "builds"
  add_foreign_key "build_items", "parts"
  add_foreign_key "builds", "users"
end
