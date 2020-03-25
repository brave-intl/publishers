class SiteBannerLookups < ActiveRecord::Base

  before_save :set_sha1_base64 if brave_publisher_id_changed?

  def set_sha1_base16
    self.sha1_base16 = Digest::SHA1.hexdigest(channel.details.brave_publisher_id)
  end
end
