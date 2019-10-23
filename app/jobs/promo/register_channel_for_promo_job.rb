# Registers a single channel for a promo immediately after verification
class Promo::RegisterChannelForPromoJob < ApplicationJob
  include PromosHelper
  queue_as :default

  def perform(channel_id:)
    channel = Channel.find(channel_id)
    Promo::AssignPromoToChannelService.new(channel: channel).perform
    Rails.logger.warn("Failed to register newly verified channel #{channel} with promo server")
  end
end
