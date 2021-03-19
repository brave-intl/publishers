class SiteBannerLookup < ActiveRecord::Base
  belongs_to :channel
  belongs_to :publisher

  connects_to database: { writing: :primary, reading: :secondary }

  def set_sha2_base16
    self.sha2_base16 = Digest::SHA2.hexdigest(channel_identifier)
  end

  # Syncs the first X nibbles, and RESPONSES_PREFIX_LENGTH refers to bytes, so we have to multiply by 2
  def sync!
    Cache::BrowserChannels::ResponsesForPrefix.perform_async(sha2_base16.first(RESPONSES_PREFIX_LENGTH * 2))
  end
end
