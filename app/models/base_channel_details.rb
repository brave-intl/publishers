class BaseChannelDetails < ActiveRecord::Base
  self.abstract_class = true

  has_one :channel, as: :details

  after_initialize :initialize_id, unless: -> { self.id }

  def channel_identifier
    raise "Override channel_identifier"
  end

  private

  def initialize_id
    self.id = SecureRandom.uuid
  end
end
