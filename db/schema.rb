# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141117160813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blog_entries", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.text     "body"
    t.string   "image",          limit: 255
    t.integer  "sticky"
    t.integer  "comments_count"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type", limit: 255
    t.string   "title",            limit: 255
    t.text     "body"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.string   "queue",      limit: 255
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "favourites", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",       limit: 255
    t.text     "address"
    t.string   "latitude",   limit: 255
    t.string   "longitude",  limit: 255
    t.string   "source",     limit: 255
    t.string   "sub_source", limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "position",               default: 0
  end

  create_table "follows", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "followable_id"
    t.string   "followable_type", limit: 255
    t.boolean  "active",                      default: true
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "issues", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",          limit: 255
    t.text     "body"
    t.string   "status",         limit: 255
    t.integer  "comments_count",             default: 0
    t.integer  "votes_count",                default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "image",          limit: 255
  end

  create_table "reported_issues", force: :cascade do |t|
    t.string   "error_type",    limit: 255
    t.text     "comment"
    t.boolean  "is_open",                   default: true
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "user_id"
    t.string   "route_segment", limit: 255
  end

  create_table "routes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "from_name",               limit: 255
    t.string   "from_latitude",           limit: 255
    t.string   "from_longitude",          limit: 255
    t.string   "to_name",                 limit: 255
    t.string   "to_latitude",             limit: 255
    t.string   "to_longitude",            limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "route_visited_locations"
    t.boolean  "is_finished",                         default: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "themes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",      limit: 255
    t.text     "body"
    t.integer  "sticky"
    t.string   "image",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "themings", force: :cascade do |t|
    t.integer  "issue_id"
    t.integer  "theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255
    t.text     "about"
    t.string   "image",                  limit: 255
    t.string   "authentication_token",   limit: 255
    t.string   "encrypted_password",     limit: 128, default: "",         null: false
    t.string   "password_salt",          limit: 255, default: "",         null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "role",                   limit: 255
    t.boolean  "notify_by_email",                    default: true
    t.boolean  "tester",                             default: false
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "account_source",         limit: 255, default: "ibikecph"
    t.string   "unconfirmed_email",      limit: 255
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
