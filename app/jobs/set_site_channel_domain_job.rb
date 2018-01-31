class SetSiteChannelDomainJob < ApplicationJob
  queue_as :default

  def perform(channel_id:)
    channel = Channel.find(channel_id)

    if channel && channel.details.brave_publisher_id_unnormalized
      SiteChannelDomainSetter.new(channel_details: channel.details).perform
      channel.details.brave_publisher_id_unnormalized = nil
      channel.save!
    end
  end
end
