class Cache::BrowserChannels::Main
  include Sidekiq::Worker

  LAST_RAN_AT_KEY = "cache_browser_channels_main_last_ran_at".freeze
  RESPONSES_PREFIX_LENGTH = 3
  def perform
    previous_run = Rails.cache.fetch(LAST_RAN_AT_KEY).to_time
    return if previous_run.present? && previous_run >= 2.hours.ago
    Cache::BrowserChannel::PrefixList.perform_async
    SiteBannerLookup
      .select("select distinct SUBSTRING(sha2_base16, 1, #{RESPONSES_PREFIX_LENGTH}) as prefix")
      .where("updated_at >= ?", previous_run - 3.minutes)
      .order(prefix: :desc).find_each do |site_banner_lookup|
      Cache::BrowserChannel::ResponsesForPrefix.perform_async(site_banner_lookup[:prefix])
    end
    Rails.cache.write(LAST_RAN_AT_KEY, Time.now.to_s)
  end
end
