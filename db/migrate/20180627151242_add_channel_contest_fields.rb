class AddChannelContestFields < ActiveRecord::Migration[5.0]
  def change
    add_column :channels, :verification_pending, :boolean, null: false, default: false

    add_column :channels, :contested_by_channel_id, :uuid, index: true
    add_foreign_key :channels, :channels, column: :contested_by_channel_id

    add_column :channels, :contest_token, :string, null: true, default: nil
    add_column :channels, :contest_timesout_at, :datetime, null: true, default: nil

    remove_index :youtube_channel_details, column: ["youtube_channel_id"], name: "index_youtube_channel_details_on_youtube_channel_id", unique: true, using: :btree
    add_index :youtube_channel_details, ["youtube_channel_id"], name: "index_youtube_channel_details_on_youtube_channel_id", unique: false, using: :btree

    remove_index :twitch_channel_details, column: ["twitch_channel_id"], name: "index_twitch_channel_details_on_twitch_channel_id", unique: true, using: :btree
    add_index :twitch_channel_details, ["twitch_channel_id"], name: "index_twitch_channel_details_on_twitch_channel_id", unique: false, using: :btree
  end
end
