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

ActiveRecord::Schema.define(version: 20170915124337) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "publishers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "brave_publisher_id"
    t.string   "name"
    t.string   "email"
    t.string   "verification_token"
    t.boolean  "verified",                              default: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "sign_in_count",                         default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "phone"
    t.string   "phone_normalized"
    t.string   "encrypted_authentication_token"
    t.string   "encrypted_authentication_token_iv"
    t.string   "verification_method"
    t.datetime "authentication_token_expires_at"
    t.boolean  "show_verification_status",              default: true
    t.boolean  "created_via_api",                       default: false, null: false
    t.string   "uphold_state_token"
    t.string   "encrypted_uphold_code"
    t.string   "encrypted_uphold_code_iv"
    t.string   "encrypted_uphold_access_parameters"
    t.string   "encrypted_uphold_access_parameters_iv"
    t.boolean  "uphold_verified",                       default: false
    t.string   "pending_email"
    t.boolean  "supports_https",                        default: false
    t.boolean  "host_connection_verified"
    t.string   "detected_web_host"
    t.index ["brave_publisher_id"], name: "index_publishers_on_brave_publisher_id", using: :btree
    t.index ["created_at"], name: "index_publishers_on_created_at", using: :btree
    t.index ["verification_token"], name: "index_publishers_on_verification_token", using: :btree
    t.index ["verified"], name: "index_publishers_on_verified", using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

end
