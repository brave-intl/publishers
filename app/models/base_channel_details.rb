# typed: true

class BaseChannelDetails < ApplicationRecord
  self.abstract_class = true

  has_one :channel, as: :details

  before_create :check_if_previously_suspended

  def check_if_previously_suspended
    if ::PreviouslySuspendedChannel.where(channel_identifier: channel_identifier).exists?
      errors.add(:base, "unable to register this channel")
      throw(:abort)
    end
  end

  def channel_identifier
    raise "Override channel_identifier"
  end
end
