# Registers a single channel for a promo immediately after verification
module Promo
  class RegisterChannelForPromoJob < ApplicationJob
    include PromosHelper
    queue_as :default

    def perform(channel:)
      Promo::PublisherChannelsRegistrar.new(publisher: channel.publisher).perform
      Rails.logger.warn("Failed to register newly verified channel #{channel} with promo server")
    end
  end
end
