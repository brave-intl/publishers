module Channels
  class RejectChannelTransfer < BaseService

    def initialize(channel:, should_delete: true)
      @channel = channel
      @contested_by = @channel.contested_by_channel
      @should_delete = should_delete

      require_contested_channel
    end

    def perform
      ActiveRecord::Base.transaction do      
        # Remove contention from original verified channel
        @channel.contested_by_channel_id = nil
        @channel.contest_token = nil
        @channel.contest_timesout_at = nil
        @channel.save!

        # Remove contention fields from contested_by channel
        @contested_by.contesting_channel = nil
        @contested_by.verification_pending = false
        @contested_by.save!
      end

      contested_by_channel_name = @contested_by.publication_title
      contested_by_publisher_name = @contested_by.publisher.name
      contested_by_publisher_email = @contested_by.publisher.email

      DeletePublisherChannelJob.perform_now(channel_id: @contested_by.id) if @should_delete

      PublisherMailer.channel_transfer_rejected_primary(@channel).deliver_later
      PublisherMailer.channel_transfer_rejected_secondary(contested_by_channel_name, contested_by_publisher_name, contested_by_publisher_email).deliver_later
      PublisherMailer.channel_transfer_rejected_primary_internal(@channel).deliver_later
      PublisherMailer.channel_transfer_rejected_secondary_internal(contested_by_channel_name, contested_by_publisher_name, contested_by_publisher_email).deliver_later
      SlackMessenger.new(message: "#{@channel.publisher.owner_identifier} has rejected the contest for #{@channel.details.channel_identifier}.").perform
    end

    private

    def require_contested_channel
      raise ChannelNotContestedError unless @channel.contest_token.present? && @contested_by.verification_pending?
    end

    class ChannelNotContestedError < RuntimeError; end
  end
end
