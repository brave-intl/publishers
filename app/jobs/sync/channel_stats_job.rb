# Syncs the stats for all channels once a day
class Sync::ChannelStatsJob < ApplicationJob
  queue_as :low

  FIRST_GROUP = ['0', '1', '2', '3', '4', '5', '6', '7'].freeze

  def perform
    YoutubeChannelDetails.joins(:channel).where(channels: {verified: true}).find_each do |youtube_channel_details|
      if should_run_for_id?(youtube_channel_details.created_at.to_i % 10)
        ChannelStatsServices::YoutubeChannelStatsService.new(youtube_channel_details: youtube_channel_details).perform
      end
    end

    TwitchChannelDetails.find_in_batches(batch_size: 30).with_index do |group, index|
      Sync::TwitchStatsJob.set(wait: index.minutes).perform_later(ids: group.map(&:id))
    end
  end

  def should_run_for_id?(number)
    number == Date.today.yday % 10
  end
end
