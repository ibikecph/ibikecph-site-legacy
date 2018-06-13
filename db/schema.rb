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

ActiveRecord::Schema.define(version: 2018_01_16_131427) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.string "queue", limit: 255
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "favourites", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 255
    t.text "address"
    t.string "latitude", limit: 255
    t.string "longitude", limit: 255
    t.string "source", limit: 255
    t.string "sub_source", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0
  end

  create_table "journeys", id: :serial, force: :cascade do |t|
    t.string "token"
    t.boolean "ready"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kortforsyningen_tickets", force: :cascade do |t|
    t.text "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "privacy_tokens", id: :serial, force: :cascade do |t|
    t.string "signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reported_issues", id: :serial, force: :cascade do |t|
    t.string "error_type", limit: 255
    t.text "comment"
    t.boolean "is_open", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "route_segment", limit: 255
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "from_name", limit: 255
    t.string "from_latitude", limit: 255
    t.string "from_longitude", limit: 255
    t.string "to_name", limit: 255
    t.string "to_latitude", limit: 255
    t.string "to_longitude", limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "route_visited_locations"
    t.boolean "is_finished", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title", limit: 255
    t.text "body"
    t.integer "sticky"
    t.string "image", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "themings", id: :serial, force: :cascade do |t|
    t.integer "issue_id"
    t.integer "theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.text "about"
    t.string "image", limit: 255
    t.string "authentication_token", limit: 255
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "password_salt", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", limit: 255
    t.boolean "notify_by_email", default: true
    t.boolean "tester", default: false
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "account_source", limit: 255, default: "ibikecph"
    t.string "unconfirmed_email", limit: 255
  end

end
