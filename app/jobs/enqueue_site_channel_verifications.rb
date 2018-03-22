# For Site Channels created recently, enqueue jobs to verify each channel
class EnqueueSiteChannelVerifications < ApplicationJob
  MAX_AGE = 6.weeks

  queue_as :scheduler

  def perform
    n = 0
    recent_unverified_site_channels_ids.each do |id|
      VerifySiteChannel.perform_later(channel_id: id)
      n += 1
    end
    Rails.logger.info("EnqueueSiteChannelVerifications enqueued VerifySiteChannels #{n} times.")
  end

  private

  # Get unverified channel ids created recently.
  def recent_unverified_site_channels_ids
    SiteChannelDetails.recent_ready_to_verify_site_channels(max_age: MAX_AGE).select(:brave_publisher_id).distinct.pluck("channels.id")
  end
end
