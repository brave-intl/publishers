# typed: false
# Registers a single channel for a promo immediately after verification
class Promo::RegisterChannelForPromoJob < ApplicationJob
  include PromosHelper
  queue_as :default

  def perform(channel_id:, attempt_count: 0)
    channel = Channel.find(channel_id)
    Promo::AssignPromoToChannelService.new(channel: channel, attempt_count: attempt_count).perform
    Rails.logger.warn("Failed to register newly verified channel #{channel} with promo server")
  end
end
