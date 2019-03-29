class ChannelTransfer < ApplicationRecord
  belongs_to :transfer_from, class_name: "Publisher"
  belongs_to :transfer_to, class_name: "Publisher"
  belongs_to :channel
end
