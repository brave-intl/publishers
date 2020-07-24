class SiteBannerLookup < ActiveRecord::Base
  belongs_to :channel
  belongs_to :publisher
  def set_sha2_base16
    self.sha2_base16 = Digest::SHA2.hexdigest(channel_identifier)
  end
end
