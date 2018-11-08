# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20160629184441) do

  create_table "lockable_users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_lockable_users_on_email"
    t.index ["uid", "provider"], name: "index_lockable_users_on_uid_and_provider", unique: true
    t.index ["unlock_token"], name: "index_lockable_users_on_unlock_token", unique: true
  end

  create_table "mangs", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_redirect_url"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "provider"
    t.string "uid", default: "", null: false
    t.text "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "favorite_color"
    t.index ["confirmation_token"], name: "index_mangs_on_confirmation_token", unique: true
    t.index ["email"], name: "index_mangs_on_email"
    t.index ["reset_password_token"], name: "index_mangs_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_mangs_on_uid_and_provider", unique: true
  end

  create_table "only_email_users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_only_email_users_on_email"
    t.index ["uid", "provider"], name: "index_only_email_users_on_uid_and_provider", unique: true
  end

  create_table "scoped_users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_scoped_users_on_email"
    t.index ["reset_password_token"], name: "index_scoped_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_scoped_users_on_uid_and_provider", unique: true
  end

  create_table "unconfirmable_users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_unconfirmable_users_on_email"
    t.index ["reset_password_token"], name: "index_unconfirmable_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_unconfirmable_users_on_uid_and_provider", unique: true
  end

  create_table "unregisterable_users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_unregisterable_users_on_email"
    t.index ["reset_password_token"], name: "index_unregisterable_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_unregisterable_users_on_uid_and_provider", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_redirect_url"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "provider"
    t.string "uid", default: "", null: false
    t.text "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "operating_thetan"
    t.string "favorite_color"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
