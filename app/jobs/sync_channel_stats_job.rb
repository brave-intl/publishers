# Syncs the stats for all channels once a day
class SyncChannelStatsJob < ApplicationJob
  queue_as :low

  def perform
    YoutubeChannelDetails.find_each do |youtube_channel_details|
      ChannelStatsServices::YoutubeChannelStatsService.new(youtube_channel_details: youtube_channel_details).perform
    end

    TwitchChannelDetails.find_each do |twitch_channel_details|
      ChannelStatsServices::TwitchChannelStatsService.new(twitch_channel_details: twitch_channel_details).perform
    end
  end
end
