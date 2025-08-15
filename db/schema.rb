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

ActiveRecord::Schema[8.0].define(version: 2025_08_15_164523) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chat_widgets", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "name", null: false
    t.string "domain", null: false
    t.string "token_digest", null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token_hash"
    t.index ["domain"], name: "index_chat_widgets_on_domain", unique: true
    t.index ["owner_id"], name: "index_chat_widgets_on_owner_id"
    t.index ["token_hash"], name: "index_chat_widgets_on_token_hash", unique: true
  end

  create_table "chats", force: :cascade do |t|
    t.string "external_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "chat_widget_id", null: false
    t.boolean "online", default: false, null: false
    t.index ["chat_widget_id"], name: "index_chats_on_chat_widget_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "chat_widget_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_widget_id"], name: "index_memberships_on_chat_widget_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.integer "role", default: 0, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "variable", null: false
    t.string "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variable"], name: "index_settings_on_variable", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chat_widgets", "users", column: "owner_id"
  add_foreign_key "chats", "chat_widgets"
  add_foreign_key "memberships", "chat_widgets"
  add_foreign_key "memberships", "users"
  add_foreign_key "messages", "chats"
end
