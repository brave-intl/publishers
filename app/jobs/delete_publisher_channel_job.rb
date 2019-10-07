class DeletePublisherChannelJob < ApplicationJob
  queue_as :default

  def perform(channel_id:)
    @channel = Channel.find(channel_id)
    publisher = @channel.publisher

    if @channel.verification_pending? && !publisher.registered_for_2fa_removal?
      Rails.logger.info("Can't remove a channel #{@channel.id} that is contesting another a channel")
      return false
    end

    # If channel is being contested, approve the channel which will also delete
    if @channel.contested_by_channel.present?
      Channels::ApproveChannelTransfer.new(channel: @channel).perform
    elsif Channel.find_by(contested_by_channel: @channel)
      # Reject the transfer if the account which is having their 2fa removed has channels transferring to their account
      Channels::RejectChannelTransfer.new(channel: @channel).perform
    else
      @channel.destroy!
    end
  end
end
