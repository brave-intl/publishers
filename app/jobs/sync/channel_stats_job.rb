# Syncs the stats for all channels once a day
class Sync::ChannelStatsJob < ApplicationJob
  queue_as :low

  def perform
    TwitchChannelDetails.find_in_batches(batch_size: 30).with_index do |group, index|
      Sync::TwitchStatsJob.set(wait: index.minutes).perform_later(ids: group.map(&:id))
    end
  end
end
