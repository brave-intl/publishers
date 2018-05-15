# Registers a single channel for a promo immediately after verification
class RegisterChannelForPromoJob < ApplicationJob
  include PromosHelper
  queue_as :default

  def perform(channel:)
    if PromoRegistrar.new(publisher: channel.publisher).perform
      PromoMailer.new_channel_registered_2018q1(channel.publisher, channel).deliver_later
    else
      Rails.logger.warn("Failed to register newly verified channel #{channel} with promo server")
    end
  end
end
