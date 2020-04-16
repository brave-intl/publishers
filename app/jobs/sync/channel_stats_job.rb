# Syncs the stats for all channels once a day
class Sync::ChannelStatsJob < ApplicationJob
  queue_as :low

  FIRST_GROUP = ['0', '1', '2', '3', '4', '5', '6', '7'].freeze

  def perform
    YoutubeChannelDetails.joins(:channel).where(channels: {verified: true}).find_each do |youtube_channel_details|
      if should_run_for_id?(youtube_channel_details.id[0])
        ChannelStatsServices::YoutubeChannelStatsService.new(youtube_channel_details: youtube_channel_details).perform
      end
    end

    TwitchChannelDetails.find_in_batches(batch_size: 30).with_index do |group, index|
      Sync::TwitchStatsJob.set(wait: index.minutes).perform_later(ids: group.map(&:id))
    end
  end

  def should_run_for_id?(first_character)
    if Date.today.yday % 2 == 0 && FIRST_GROUP.include?(first_character)
      true
    elsif Date.today.yday % 2 == 1 && !FIRST_GROUP.include?(first_character) # Part of second group
      true
    else
      false
    end
  end
end
