class ChannelTransfer < ApplicationRecord
  belongs_to :transfer_from, class_name: "Publisher"
  belongs_to :transfer_to, class_name: "Publisher"
  belongs_to :channel
  belongs_to :transfer_to_channel, class_name: "Channel"
end
