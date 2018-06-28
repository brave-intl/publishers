module Channels
  class ApproveChannelTransfer < BaseService
    def initialize(channel:)
      @channel = channel
    end

    def perform
      contested_by = @channel.contested_by_channel

      contested_by.verified = true
      contested_by.verification_pending = false
      contested_by.save!

      channel_email = @channel.publisher.email
      channel_name = @channel.publication_title

      @channel.verified = false
      @channel.contested_by_channel_id = nil
      @channel.contest_token = nil
      @channel.contest_timesout_at = nil
      @channel.destroy!

      # Delete the channel from eyeshade and clean up the promo registration
      update_promo_server = @channel.promo_registration.present?
      if update_promo_server
        referral_code = @channel.promo_registration.referral_code
      else
        referral_code = nil
      end

      DeletePublisherChannelJob.perform_now(publisher_id: @channel.publisher.id,
                                            channel_identifier: @channel.details.channel_identifier,
                                            update_promo_server: update_promo_server,
                                            referral_code: referral_code)

      PublisherMailer.channel_transfer_approved_primary(channel_email, channel_name).deliver_later
      PublisherMailer.channel_transfer_approved_primary_internal(channel_email, channel_name).deliver_later

      channel_email = contested_by.publisher.email
      channel_name = contested_by.publication_title

      PublisherMailer.channel_transfer_approved_secondary(channel_email, channel_name).deliver_later
      PublisherMailer.channel_transfer_approved_secondary_internal(channel_email, channel_name).deliver_later
    end
  end
end