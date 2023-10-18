# typed: strict

class ChannelTransfer < ApplicationRecord
  belongs_to :transfer_from, class_name: "Publisher"
  belongs_to :transfer_to, class_name: "Publisher"
  belongs_to :channel
  belongs_to :transfer_to_channel, class_name: "Channel"

  validate :no_suspensions

  def no_suspensions
    if !transfer_from.active?
      errors.add(:transfer_from, "needs to be active")
    end
    if !transfer_to.active?
      errors.add(:transfer_to, "needs to be active")
    end
  end
end
