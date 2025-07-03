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

ActiveRecord::Schema[8.0].define(version: 2025_07_02_101454) do
  create_table "pending_seats", force: :cascade do |t|
    t.string "team_id"
    t.string "email_address"
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_pending_seats_on_email_address"
    t.index ["team_id"], name: "index_pending_seats_on_team_id"
    t.index ["token"], name: "index_pending_seats_on_token"
  end

  create_table "seats", force: :cascade do |t|
    t.string "team_id", null: false
    t.string "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_seats_on_team_id"
    t.index ["user_id"], name: "index_seats_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "statuses", id: :string, force: :cascade do |t|
    t.string "team_id", null: false
    t.string "user_id", null: false
    t.json "sections"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_statuses_on_created_at"
    t.index ["team_id"], name: "index_statuses_on_team_id"
    t.index ["user_id"], name: "index_statuses_on_user_id"
  end

  create_table "teams", id: :string, force: :cascade do |t|
    t.string "user_id", null: false
    t.string "name", limit: 120
    t.json "sections", default: [{"name"=>"Yesterday"}, {"name"=>"Today"}, {"name"=>"Links", "description"=>"Read anything good?"}]
    t.datetime "notifaction_time", default: "2025-05-17 09:30:00"
    t.datetime "end_of_day", default: "2025-05-17 15:00:00", null: false
    t.string "time_zone", default: "Central Time (US & Canada)"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "team_id"
    t.string "domain"
    t.string "token"
    t.string "oauth_scope"
    t.string "oauth_version", default: "v1", null: false
    t.string "bot_user_id"
    t.string "activated_user_id"
    t.string "activated_user_access_token"
    t.boolean "active", default: true
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "name", limit: 60
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slack_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "pending_seats", "teams"
  add_foreign_key "seats", "teams"
  add_foreign_key "seats", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "statuses", "teams"
  add_foreign_key "statuses", "users"
  add_foreign_key "teams", "users"
end
