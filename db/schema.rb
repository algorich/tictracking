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

ActiveRecord::Schema.define(version: 20130915002204) do

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "events", force: true do |t|
    t.integer  "nightclub_id"
    t.string   "name"
    t.text     "description"
    t.datetime "date"
    t.integer  "stocking"
    t.string   "profile_file_name"
    t.string   "profile_content_type"
    t.integer  "profile_file_size"
    t.datetime "profile_updated_at"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.string   "flyer_file_name"
    t.string   "flyer_content_type"
    t.integer  "flyer_file_size"
    t.datetime "flyer_updated_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "slug"
  end

  add_index "events", ["slug"], name: "index_events_on_slug", using: :btree

  create_table "followed_nighclubs_followers", force: true do |t|
    t.integer "nightclub_id"
    t.integer "user_id"
  end

  create_table "friendships", force: true do |t|
    t.integer  "inviter_id"
    t.integer  "invited_id"
    t.boolean  "pending",    default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "role",       default: "common_user"
  end

  add_index "memberships", ["project_id"], name: "index_memberships_on_project_id", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "nightclubs", force: true do |t|
    t.integer  "place_id"
    t.integer  "owner_id"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "googleplus"
    t.string   "youtube"
    t.string   "site"
    t.string   "name"
    t.text     "description"
    t.string   "profile_file_name"
    t.string   "profile_content_type"
    t.integer  "profile_file_size"
    t.datetime "profile_updated_at"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "paypal_email"
    t.string   "slug"
  end

  add_index "nightclubs", ["slug"], name: "index_nightclubs_on_slug", using: :btree

  create_table "nightclubs_users", id: false, force: true do |t|
    t.integer "nightclub_id"
    t.integer "user_id"
  end

  create_table "notifications", force: true do |t|
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "redirect_id"
    t.string   "redirect_type"
    t.integer  "subject"
    t.string   "permalink"
    t.boolean  "read",            default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "remote_redirect", default: false
  end

  create_table "orders", force: true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.float    "value"
    t.integer  "status",                   default: 0
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "pay_key"
    t.string   "transaction_id"
    t.integer  "nightclub_payment_status", default: 0
  end

  create_table "packs", force: true do |t|
    t.integer  "event_id"
    t.string   "name"
    t.float    "price"
    t.integer  "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "places", force: true do |t|
    t.string   "postal_code"
    t.string   "street"
    t.string   "number"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "state"
    t.string   "complement"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "entity"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: true do |t|
    t.integer  "order_id"
    t.integer  "pack_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "document"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "worktimes", force: true do |t|
    t.datetime "beginning"
    t.datetime "finish"
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "time_worked", default: 0
  end

end
