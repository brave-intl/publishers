class CreateTwitterChannelDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_channel_details, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string   "twitter_channel_id"
      t.string   "auth_provider"
      t.string   "auth_email"
      t.string   "name"
      t.string   "screen_name"
      t.string   "thumbnail_url"
      t.jsonb    "stats"
      t.datetime "created_at",         null: false
      t.datetime "updated_at",         null: false
      t.index ["twitter_channel_id"], name: "index_twitter_channel_details_on_twitter_channel_id", unique: true, using: :btree
    end
  end
end
