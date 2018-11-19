class CleanAbandonedSiteChannelsJob < ApplicationJob
  queue_as :scheduler

  def perform
    # clear all abandoned site channels where a site channel is considered abandoned if it has no verification token,
    # and the publisher's session has expired. This ensures the channel will not be visible to them again and can
    # be safely deleted.

    channels = Channel.not_visible_site_channels
    n = 0
    channels.joins(:site_channel_details).each do |channel|
      raise unless channel.details.verification_method.nil?
      channel.destroy
      n = n + 1
      Rails.logger.info("Cleaned abandoned site channel #{ channel.details.brave_publisher_id } for publisher #{ channel.publisher_id }.")
    end
    Rails.logger.info("CleanAbandonedSiteChannelsJob cleared #{n} abandoned site channels.")
  end
end
