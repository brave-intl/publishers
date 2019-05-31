class DeletePublisherChannelJob < ApplicationJob
  queue_as :default

  class CannotDeleteChannel < StandardError; end

  def perform(channel_id:)
    @channel = Channel.find(channel_id)
    publisher = @channel.publisher

    if @channel.verification_pending? && !publisher.registered_for_2fa_removal?
      raise CannotDeleteChannel.new("Can't remove a channel that is contesting another a channel or is in the process of removing 2fa.")
    end

    # If channel is being contested, approve the channel which will also delete
    if @channel.contested_by_channel.present?
      return Channels::ApproveChannelTransfer.new(channel: @channel).perform
    end

    channel_is_verified = @channel.verified?

    if should_update_promo_server
      referral_code = @channel.promo_registration.referral_code
    end

    success = @channel.destroy!

    # Update Eyeshade and Promo
    if success && channel_is_verified && should_update_promo_server
      Promo::ChannelOwnerUpdater.new(referral_code: referral_code).perform
    end

    success
  end

  private

  def should_update_promo_server
    @channel.promo_registration.present?
  end
end
