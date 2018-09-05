module Channels
  class ApproveChannelTransfer < BaseService

    def initialize(channel:, should_delete: true)
      @channel = channel
      @should_delete = should_delete
    end

    def perform
      ActiveRecord::Base.transaction do
        contested_by = @channel.contested_by_channel
        contested_by.verified = true
        contested_by.verification_pending = false
        contested_by.save!
        
        # Verify the contested_by channel
        original_owner_email = @channel.publisher.email
        channel_name = @channel.publication_title

        # Unverify and destroy original channel
        @channel.verified = false
        @channel.contested_by_channel_id = nil
        @channel.contest_token = nil
        @channel.contest_timesout_at = nil
        @channel.save!
        
        original_owner_email = @channel.publisher.email
        original_owner_name = @channel.publisher.name
        channel_name = @channel.publication_title

        # Delete the channel from eyeshade and clean up the promo registration
        DeletePublisherChannelJob.perform_now(channel_id: @channel.id) if @should_delete

        # Email the original owner
        PublisherMailer.channel_transfer_approved_primary(channel_name, original_owner_name, original_owner_email).deliver_later
        PublisherMailer.channel_transfer_approved_primary_internal(channel_name, original_owner_name, original_owner_email).deliver_later

        new_owner_email = contested_by.publisher.email
        channel_name = contested_by.publication_title

        # Email the new owner
        PublisherMailer.channel_transfer_approved_secondary(contested_by).deliver_later
        PublisherMailer.channel_transfer_approved_secondary_internal(contested_by).deliver_later

        # Notify Slack
        SlackMessenger.new(message: "#{@channel.details.channel_identifier} has been successfully contested by #{@channel.publisher.owner_identifier}.").perform
      end
    end
  end
end
