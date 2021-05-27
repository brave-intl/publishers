class BaseChannelDetails < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :secondary }

  has_one :channel, as: :details

  def channel_identifier
    raise "Override channel_identifier"
  end
end
