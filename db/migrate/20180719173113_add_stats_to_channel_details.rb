class AddStatsToChannelDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :site_channel_details, :stats, :jsonb, null: false, default: '{}'
    add_column :youtube_channel_details, :stats, :jsonb, null: false, default: '{}'
    add_column :twitch_channel_details, :stats, :jsonb, null: false, default: '{}'
  end
end
