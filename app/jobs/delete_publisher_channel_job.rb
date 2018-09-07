class DeletePublisherChannelJob < ApplicationJob
  queue_as :default

  attr_reader :channel, :publisher

  def perform(channel_id:)
    @channel = Channel.find(channel_id)
    publisher = @channel.publisher

    if @channel.contested_by_channel.present?
      Channels::ApproveChannelTransfer.new(channel: @channel, should_delete: false).perform
    elsif @channel.verification_pending?
      raise "Can't remove a channel that is contesting another a channel."
    end

    success = @channel.destroy

    # Update Eyeshade and Promo
    if success && @channel.verified?
      PublisherEyeshadeChannelDeleter.new(publisher: publisher, channel_identifier: @channel.details.channel_identifier).perform

      if should_update_promo_server
        PromoChannelOwnerUpdater.new(referral_code: channel.promo_registration.referral_code).perform
      end
    end

    success
  end

  private

  def should_update_promo_server
    channel.promo_registration.present?
  end
end
