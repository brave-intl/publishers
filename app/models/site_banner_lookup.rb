class SiteBannerLookup < ActiveRecord::Base

  before_save :set_sha2_base64 if brave_publisher_id_changed?

  def set_sha2_base16
    self.sha2_base16 = Digest::SHA2.hexdigest(channel_identifier)
  end
end
