module Channels
  class RejectChannelTransfer < BaseService
    def initialize(channel:)
      @channel = channel
    end

    def perform
      contested_by = @channel.contested_by_channel

      @channel.contested_by_channel_id = nil
      @channel.contest_token = nil
      @channel.contest_timesout_at = nil
      @channel.save!

      contested_by_email = contested_by.publisher.email
      contested_by_channel_name = contested_by.publication_title

      contested_by.destroy!

      PublisherMailer.channel_transfer_rejected_primary(@channel).deliver_later
      PublisherMailer.channel_transfer_rejected_secondary(contested_by_email, contested_by_channel_name).deliver_later
      PublisherMailer.channel_transfer_rejected_primary_internal(@channel).deliver_later
      PublisherMailer.channel_transfer_rejected_secondary_internal(contested_by_email, contested_by_channel_name).deliver_later
    end
  end
end