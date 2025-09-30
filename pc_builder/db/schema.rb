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

ActiveRecord::Schema[8.0].define(version: 2025_09_30_154447) do
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
    t.string "share_token"
    t.text "shared_data"
    t.datetime "shared_at"
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
    t.decimal "cpu_core_clock"
    t.decimal "cpu_boost_clock"
    t.integer "gpu_memory"
    t.string "gpu_memory_type"
    t.integer "gpu_core_clock_mhz"
    t.integer "gpu_core_boost_mhz"
    t.string "mb_socket"
    t.string "mb_chipset"
    t.string "mb_form_factor"
    t.integer "mb_ram_slots"
    t.integer "mb_max_ram_gb"
    t.string "mem_type"
    t.integer "mem_kit_capacity_gb"
    t.integer "mem_modules"
    t.integer "mem_speed_mhz"
    t.integer "mem_first_word_latency"
    t.string "stor_type"
    t.string "stor_interface"
    t.integer "stor_capacity_gb"
    t.string "cooler_type"
    t.integer "cooler_fan_size_mm"
    t.string "cooler_sockets"
    t.string "case_type"
    t.string "case_supported_mb"
    t.string "case_color"
    t.string "psu_efficiency"
    t.string "psu_modularity"
    t.string "psu_wattage"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "build_items", "builds"
  add_foreign_key "build_items", "parts"
  add_foreign_key "builds", "users"
end
