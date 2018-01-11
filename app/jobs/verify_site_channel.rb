# Verify a Site Channel, by id
class VerifySiteChannel < ApplicationJob
  queue_as :default

  require "faraday"
  rescue_from(Faraday::ResourceNotFound) do
    Rails.logger.warn("SiteChannelVerifier 404; publisher might not exist in eyeshade.")
  end

  def perform(channel_id:)
    channel = Channel.find(channel_id)

    SiteChannelVerifier.new(
      attended: false,
      channel: channel
    ).perform
  end
end
