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

ActiveRecord::Schema.define(version: 20161101222248) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "publisher_legal_forms", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "publisher_id",                         null: false
    t.string   "form_type"
    t.string   "docusign_envelope_id"
    t.string   "docusign_template_id"
    t.string   "status"
    t.string   "after_sign_token"
    t.datetime "after_sign_token_expires_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "docusign_envelope_gotten_at"
    t.string   "encrypted_s3_key"
    t.string   "encrypted_s3_key_iv"
    t.datetime "docusign_envelope_document_gotten_at"
    t.index ["after_sign_token"], name: "index_publisher_legal_forms_on_after_sign_token", using: :btree
    t.index ["publisher_id"], name: "index_publisher_legal_forms_on_publisher_id", using: :btree
  end

  create_table "publishers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "brave_publisher_id"
    t.string   "name"
    t.string   "email"
    t.string   "verification_token"
    t.boolean  "verified",                          default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "phone"
    t.string   "phone_normalized"
    t.string   "encrypted_bitcoin_address"
    t.string   "encrypted_bitcoin_address_iv"
    t.string   "encrypted_authentication_token"
    t.string   "encrypted_authentication_token_iv"
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
