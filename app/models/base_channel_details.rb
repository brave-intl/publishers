class BaseChannelDetails < ActiveRecord::Base
  self.abstract_class = true

  has_one :channel, as: :details

  def channel_identifier
    raise "Override channel_identifier"
  end
end
