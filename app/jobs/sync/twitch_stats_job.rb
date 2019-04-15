module Sync
  class TwitchStatsJob < ApplicationJob
    queue_as :low

    def perform(ids: [])
      # This will take in a batch of IDs, so that we don't hit our Twitch rate limit :)
      TwitchChannelDetails.find(ids).each do |channel|
        ChannelStatsServices::TwitchChannelStatsService.new(twitch_channel_details: channel).perform
      end
    end
  end
end
