class PublisherChannelDeleter < BaseService

  def initialize(channel:)
    @channel = channel
    @publisher = channel.publisher
  end

  def perform
    should_update_promo_server = @channel.promo_registration.present?
    referral_code = should_update_promo_server ? @channel.promo_registration.referral_code : nil

    if @channel.contested_by_channel
      # Channel is being contested
      Channels::ApproveChannelTransfer.new(channel: @channel, should_delete: false).perform    
    elsif @channel.verification_pending
      raise "Can't remove a channel that is contesting another a channel."
    end

    success = @channel.destroy

    # Update Eyeshade and Promo
    if success && @channel.verified?
       DeletePublisherChannelJob.perform_later(publisher_id: @publisher.id, 
                                              channel_identifier: @channel.details.channel_identifier, 
                                              should_update_promo_server: should_update_promo_server,
                                              referral_code: referral_code)
    end
    success
  end
end
