class RenameRecreateTotpU2f < ActiveRecord::Migration[5.0]
  def change
    rename_table :totp_registrations, :legacy_totp_registrations
    rename_table :u2f_registrations, :legacy_u2f_registrations

    create_table "totp_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string   "encrypted_secret"
      t.string   "encrypted_secret_iv"
      t.uuid     "publisher_id"
      t.datetime "last_logged_in_at"
      t.datetime "created_at",          null: false
      t.datetime "updated_at",          null: false
      t.index ["publisher_id"], name: "index_totp_registrations_on_publisher_id", using: :btree
    end

    create_table "u2f_registrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.text     "certificate"
      t.string   "key_handle"
      t.string   "public_key"
      t.integer  "counter",      null: false
      t.string   "name"
      t.uuid     "publisher_id"
      t.datetime "created_at",   null: false
      t.datetime "updated_at",   null: false
      t.index ["key_handle"], name: "index_u2f_registrations_on_key_handle", using: :btree
      t.index ["publisher_id"], name: "index_u2f_registrations_on_publisher_id", using: :btree
    end

  end
end
