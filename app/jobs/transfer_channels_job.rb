# Complete transfer for channels that have not rejected the transfer before the timeout
class TransferChannelsJob < ApplicationJob

  queue_as :scheduler

  def perform
    n = 0
    Channel.contested_channels_ready_to_transfer.each do |channel|
      Channels::ApproveChannelTransfer.new(channel: channel).perform
      n += 1
    end
    Rails.logger.info("TransferChannelsJob approved #{n} channels")
  end
end
