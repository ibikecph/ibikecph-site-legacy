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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130605042950) do

  create_table "blog_entries", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "image"
    t.integer  "sticky"
    t.integer  "comments_count"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "user_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.string   "queue"
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "favourites", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "address"
    t.string   "lattitude"
    t.string   "longitude"
    t.string   "source"
    t.string   "sub_source"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "position",   :default => 0
  end

  create_table "follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "followable_id"
    t.string   "followable_type"
    t.boolean  "active",          :default => true
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "issues", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.string   "status"
    t.integer  "comments_count", :default => 0
    t.integer  "votes_count",    :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "image"
  end

  create_table "reported_issues", :force => true do |t|
    t.string   "error_type"
    t.text     "comment"
    t.boolean  "is_open",       :default => true
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "user_id"
    t.string   "route_segment"
  end

  create_table "routes", :force => true do |t|
    t.integer  "user_id"
    t.string   "from_name"
    t.string   "from_lattitude"
    t.string   "from_longitude"
    t.string   "to_name"
    t.string   "to_lattitude"
    t.string   "to_longitude"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "route_visited_locations"
    t.boolean  "is_finished",             :default => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "themes", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.integer  "sticky"
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "themings", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "theme_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "about"
    t.string   "image"
    t.string   "authentication_token"
    t.string   "encrypted_password",     :limit => 128, :default => "",         :null => false
    t.string   "password_salt",                         :default => "",         :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "role"
    t.boolean  "notify_by_email",                       :default => true
    t.boolean  "tester",                                :default => false
    t.string   "provider"
    t.string   "uid"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "account_source",                        :default => "ibikecph"
  end

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "issue_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
