class Cache::BrowserChannels::ResponsesForPrefix
  include Sidekiq::Worker

  def perform(prefix:)
    site_banner_lookups = SiteBannerLookup.where("sha_base16 LIKE #{prefix}%")
    
  end
end
