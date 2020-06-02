class Cache::BrowserChannels::Main
  include Sidekiq::Worker
  sidekiq_options queue: :scheduler, retry: false

  LAST_RAN_AT_KEY = "cache_browser_channels_main_last_ran_at".freeze
  RESPONSES_PREFIX_LENGTH = 2
  def perform
    previous_run = Rails.cache.fetch(LAST_RAN_AT_KEY)
    return if previous_run.present? && previous_run.to_time >= 2.hours.ago
    Cache::BrowserChannels::PrefixList.perform_async
    previous_run =
      if previous_run.present?
        (previous_run.to_time - 3.minutes).to_s
      else
        Time.at(0).to_s
      end

    result = SiteBannerLookup.find_by_sql(["
      SELECT DISTINCT SUBSTRING(sha2_base16, 1, :nibble_length) as prefix
      FROM site_banner_lookups
      WHERE wallet_status != 0
      AND updated_at >= :previous_run
      ORDER BY prefix desc",
      {
        nibble_length: RESPONSES_PREFIX_LENGTH * 2,
        previous_run: previous_run
      }
    ])
    result.each do |site_banner_lookup|
      Cache::BrowserChannels::ResponsesForPrefix.perform_async(site_banner_lookup[:prefix])
    end
    Rails.cache.write(LAST_RAN_AT_KEY, Time.now.to_s)
  end
end
