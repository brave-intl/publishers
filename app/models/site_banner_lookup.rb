class SiteBannerLookup < ApplicationRecord
  belongs_to :channel
  belongs_to :publisher

  after_destroy :sync!

  NIBBLE_LENGTH_FOR_RESPONSES = 4

  def set_sha2_base16
    self.sha2_base16 = Digest::SHA2.hexdigest(channel_identifier)
  end

  def sync!
    Cache::BrowserChannels::ResponsesForPrefix.perform_async(sha2_base16.first(NIBBLE_LENGTH_FOR_RESPONSES))
  end
end
