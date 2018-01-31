class RenameRecreateStatements < ActiveRecord::Migration[5.0]
  def change
    rename_table :publisher_statements, :legacy_publisher_statements

    create_table "publisher_statements", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid     "publisher_id",          null: false
      t.string   "period"
      t.string   "source_url"
      t.text     "encrypted_contents"
      t.string   "encrypted_contents_iv"
      t.datetime "expires_at"
      t.datetime "created_at",            null: false
      t.datetime "updated_at",            null: false
      t.index ["publisher_id"], name: "index_publisher_statements_on_publisher_id", using: :btree
    end
  end
end
