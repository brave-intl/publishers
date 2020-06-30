# Complete transfer for channels that have not rejected the transfer before the timeout
module Channels
  class TransferChannelsJob < ApplicationJob
    queue_as :scheduler

    def perform
      Channel.contested_channels_ready_to_transfer.each do |channel|
        Channels::ApproveChannelTransferJob.perform_later(channel_id: channel.id)
      end
    end
  end
end
