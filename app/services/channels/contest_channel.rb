module Channels
  class ContestChannel < BaseService
    def initialize(channel:, contested_by:)
      @channel = channel
      @contested_by = contested_by
    end

    def perform
      @contested_by.verified = false
      @contested_by.verification_pending = true
      @contested_by.save!

      # Reject prior channels contesting the same channel
      if @channel.contested_by_channel_id
        Channels::RejectChannelTransfer.new(channel: @channel).perform
      end

      @channel.contested_by_channel_id = @contested_by.id
      @channel.contest_token = SecureRandom.hex(32)
      @channel.contest_timesout_at = Time.now + 3.days
      @channel.save!

      PublisherMailer.channel_contested(@channel).deliver_later
      PublisherMailer.channel_contested_internal(@channel).deliver_later
    end
  end
end