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
    else
      @channel.destroy!
    end
  end
end
