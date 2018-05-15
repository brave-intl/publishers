class DeletePublisherChannelJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:, channel_identifier:, update_promo_server:, referral_code:)
    publisher = Publisher.find(publisher_id)

    PublisherChannelDeleter.new(publisher: publisher, channel_identifier: channel_identifier).perform

    if update_promo_server
      PromoChannelOwnerUpdater.new(referral_code: referral_code).perform
    end
  end
end