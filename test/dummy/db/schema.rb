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

ActiveRecord::Schema.define(version: 20190924101113) do

  create_table "ar_internal_metadata", primary_key: "key", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", limit: 6, null: false
    t.datetime "updated_at", limit: 6, null: false
  end

  create_table "confirmable_users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean  "allow_password_change",  default: false
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "confirmable_users", ["confirmation_token"], name: "index_confirmable_users_on_confirmation_token", unique: true
  add_index "confirmable_users", ["email"], name: "index_confirmable_users_on_email", unique: true
  add_index "confirmable_users", ["reset_password_token"], name: "index_confirmable_users_on_reset_password_token", unique: true
  add_index "confirmable_users", ["uid", "provider"], name: "index_confirmable_users_on_uid_and_provider", unique: true

  create_table "lockable_users", force: :cascade do |t|
    t.string   "provider",                        null: false
    t.string   "uid",                default: "", null: false
    t.string   "encrypted_password", default: "", null: false
    t.integer  "failed_attempts",    default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lockable_users", ["email"], name: "index_lockable_users_on_email"
  add_index "lockable_users", ["uid", "provider"], name: "index_lockable_users_on_uid_and_provider", unique: true
  add_index "lockable_users", ["unlock_token"], name: "index_lockable_users_on_unlock_token", unique: true

  create_table "mangs", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password",          default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "reset_password_redirect_url"
    t.boolean  "allow_password_change",       default: false
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "provider"
    t.string   "uid",                         default: "",    null: false
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "favorite_color"
  end

  add_index "mangs", ["confirmation_token"], name: "index_mangs_on_confirmation_token", unique: true
  add_index "mangs", ["email"], name: "index_mangs_on_email"
  add_index "mangs", ["reset_password_token"], name: "index_mangs_on_reset_password_token", unique: true
  add_index "mangs", ["uid", "provider"], name: "index_mangs_on_uid_and_provider", unique: true

  create_table "only_email_users", force: :cascade do |t|
    t.string   "provider",                        null: false
    t.string   "uid",                default: "", null: false
    t.string   "encrypted_password", default: "", null: false
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "only_email_users", ["email"], name: "index_only_email_users_on_email"
  add_index "only_email_users", ["uid", "provider"], name: "index_only_email_users_on_uid_and_provider", unique: true

  create_table "scoped_users", force: :cascade do |t|
    t.string   "provider",                               null: false
    t.string   "uid",                    default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean  "allow_password_change",  default: false
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scoped_users", ["email"], name: "index_scoped_users_on_email"
  add_index "scoped_users", ["reset_password_token"], name: "index_scoped_users_on_reset_password_token", unique: true
  add_index "scoped_users", ["uid", "provider"], name: "index_scoped_users_on_uid_and_provider", unique: true

  create_table "unconfirmable_users", force: :cascade do |t|
    t.string   "provider",                               null: false
    t.string   "uid",                    default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean  "allow_password_change",  default: false
    t.datetime "remember_created_at"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unconfirmable_users", ["email"], name: "index_unconfirmable_users_on_email"
  add_index "unconfirmable_users", ["reset_password_token"], name: "index_unconfirmable_users_on_reset_password_token", unique: true
  add_index "unconfirmable_users", ["uid", "provider"], name: "index_unconfirmable_users_on_uid_and_provider", unique: true

  create_table "unregisterable_users", force: :cascade do |t|
    t.string   "provider",                               null: false
    t.string   "uid",                    default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean  "allow_password_change",  default: false
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unregisterable_users", ["email"], name: "index_unregisterable_users_on_email"
  add_index "unregisterable_users", ["reset_password_token"], name: "index_unregisterable_users_on_reset_password_token", unique: true
  add_index "unregisterable_users", ["uid", "provider"], name: "index_unregisterable_users_on_uid_and_provider", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password",          default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "reset_password_redirect_url"
    t.boolean  "allow_password_change",       default: false
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "provider"
    t.string   "uid",                         default: "",    null: false
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "operating_thetan"
    t.string   "favorite_color"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["nickname"], name: "index_users_on_nickname", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true

end
