class CleanAbandonedSiteChannelsJob < ApplicationJob
  queue_as :scheduler

  def perform
    require "sentry-raven"
    # clear all abandoned site channels where a site channel is considered abandoned if it has no verification token,
    # and the publisher's session has expired. This ensures the channel will not be visible to them again and can
    # be safely deleted.

    channel_details = SiteChannelDetails.abandoned
    n = 0
    channel_details.each do |details|
      raise unless details.verification_token.nil?

      details.channel.destroy
      n = n + 1

      Rails.logger.info("Cleaned abandoned site channel #{ details.brave_publisher_id } for #{ details.channel.publisher_id }.")
      Raven.capture_message("Cleaned abandoned site channel #{ details.brave_publisher_id } for #{ details.channel.publisher_id }.")
    end
    Rails.logger.info("CleanAbandonedSiteChannelsJob cleared #{n} abandoned site channels.")
    Raven.capture_message("CleanAbandonedSiteChannelsJob cleared #{n} abandoned site channels.")
  end
end
