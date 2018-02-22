class CreateTwitchChannelDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :twitch_channel_details, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string   "twitch_channel_id"
      t.string   "auth_provider"
      t.string   "auth_user_id"
      t.string   "email"
      t.string   "name"
      t.string   "display_name"
      t.string   "thumbnail_url"
      t.datetime "created_at",         null: false
      t.datetime "updated_at",         null: false
      t.index ["twitch_channel_id"], name: "index_twitch_channel_details_on_twitch_channel_id", unique: true, using: :btree
    end
  end
end
