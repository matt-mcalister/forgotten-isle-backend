# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180221184605) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_games", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "game_id"
    t.integer "position"
    t.string "ability"
    t.string "treasure_cards", array: true
    t.boolean "ready_to_start", default: false
    t.integer "actions_remaining", default: 0
    t.boolean "turn_action", default: false
    t.integer "navigations_remaining", default: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_active_games_on_game_id"
    t.index ["user_id"], name: "index_active_games_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.integer "water_level"
    t.string "flood_cards", array: true
    t.string "flood_discards", array: true
    t.string "treasure_cards", array: true
    t.string "treasure_discards", array: true
    t.boolean "in_session", default: false
    t.integer "current_turn_id"
    t.string "treasures_obtained", array: true
    t.string "end_game"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "active_game_id"
    t.string "text"
    t.string "alert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_game_id"], name: "index_messages_on_active_game_id"
  end

  create_table "tiles", force: :cascade do |t|
    t.bigint "game_id"
    t.string "name"
    t.string "status"
    t.integer "position"
    t.string "treasure"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_tiles_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_games", "games"
  add_foreign_key "active_games", "users"
  add_foreign_key "messages", "active_games"
  add_foreign_key "tiles", "games"
end
