module Channels
  class ContestChannel < BaseService
    def initialize(channel:, contested_by:)
      @channel = channel
      @contested_by = contested_by
      require_same_channel_id
    end

    def perform
      ChannelTransfer.create(transfer_from: @channel.publisher, transfer_to: @contested_by.publisher, channel: @channel, suspended: @channel.publisher.suspended?)
      raise SuspendedPublisherError if @channel.publisher.suspended?

      ActiveRecord::Base.transaction do
        @contested_by.verified = false
        @contested_by.verification_pending = true
        @contested_by.save!

        # Reject prior channels contesting the same channel
        if @channel.contested_by_channel_id
          Channels::RejectChannelTransfer.new(channel: @channel).perform
        end

        @channel.contested_by_channel_id = @contested_by.id
        @channel.contest_token = SecureRandom.hex(32)
        @channel.contest_timesout_at = Time.now + Channel::CONTEST_TIMEOUT
        @channel.save!
      end

      PublisherMailer.channel_contested(@channel).deliver_later
      PublisherMailer.channel_contested_internal(@channel).deliver_later
      SlackMessenger.new(message: "#{@channel.details.channel_identifier} has been successfully contested.").perform
    end

    private

    def require_same_channel_id
      raise ChannelTypeMismatchError if @channel.details_type != @contested_by.details_type

      # TODO Abstract
      channel_ids_match = case @channel.details_type
        when "SiteChannelDetails"
          @channel.details.brave_publisher_id == @contested_by.details.brave_publisher_id
        when "YoutubeChannelDetails"
          @channel.details.youtube_channel_id == @contested_by.details.youtube_channel_id
        when "TwitchChannelDetails"
          @channel.details.twitch_channel_id == @contested_by.details.twitch_channel_id
        when "TwitterChannelDetails"
          @channel.details.twitter_channel_id == @contested_by.details.twitter_channel_id
        when "VimeoChannelDetails"
          @channel.details.vimeo_channel_id == @contested_by.details.vimeo_channel_id
      end

      raise ChannelIdMismatchError if !channel_ids_match
    end

    class ChannelTypeMismatchError < RuntimeError; end
    class ChannelIdMismatchError < RuntimeError; end
    class SuspendedPublisherError < RuntimeError; end
  end
end
