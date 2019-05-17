class CreateRedditChannelDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :reddit_channel_details, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.string   "reddit_channel_id"
      t.string   "auth_provider"
      t.string   "name"
      t.string   "channel_url"
      t.string   "nickname"
      t.string   "thumbnail_url"
      t.jsonb    "stats"
      t.timestamps
    end
  end
end
