# typed: false
class Cache::BrowserChannels::Main
  include Sidekiq::Worker
  sidekiq_options queue: :scheduler, retry: false

  LAST_RAN_AT_KEY = "cache_browser_channels_main_last_ran_at".freeze
  LAST_RAN_ALL_KEY = "cache_browser_channels_main_last_ran_all".freeze

  def perform
    previous_run = Rails.cache.fetch(LAST_RAN_AT_KEY)
    all_prefixes_run_time = Rails.cache.fetch(LAST_RAN_ALL_KEY)
    return if previous_run.present? && previous_run.to_time >= 2.hours.ago
    Cache::BrowserChannels::PrefixList.perform_async
    previous_run =
      if previous_run.present?
        (previous_run.to_time - 3.minutes).to_s
      else
        Time.at(0).to_s
      end
    if full_refresh_not_ran_recently?(all_prefixes_run_time: all_prefixes_run_time) && queue_depth_small?
      run_all_prefixes
      Rails.cache.write(LAST_RAN_ALL_KEY, Time.now.to_s)
    else
      run_changed_prefixes(previous_run: previous_run)
    end

    Rails.cache.write(LAST_RAN_AT_KEY, Time.now.to_s)
  end

  def full_refresh_not_ran_recently?(all_prefixes_run_time:)
    return true if all_prefixes_run_time.nil?
    all_prefixes_run_time.to_time <= 24.hours.ago
  end

  def queue_depth_small?
    Sidekiq::Queue.new("low").size <= 10000
  end

  def run_all_prefixes
    result = SiteBannerLookup.find_by_sql(["
      SELECT DISTINCT SUBSTRING(sha2_base16, 1, :nibble_length) as prefix
      FROM site_banner_lookups
      ORDER BY prefix desc",
      {
        nibble_length: SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES
      }])
    result.each do |site_banner_lookup|
      Cache::BrowserChannels::ResponsesForPrefix.perform_async(site_banner_lookup[:prefix])
    end
  end

  def run_changed_prefixes(previous_run:)
    result = SiteBannerLookup.find_by_sql(["
      SELECT DISTINCT SUBSTRING(sha2_base16, 1, :nibble_length) as prefix
      FROM site_banner_lookups
      WHERE updated_at >= :previous_run
      ORDER BY prefix desc",
      {
        nibble_length: SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES,
        previous_run: previous_run
      }])
    result.each do |site_banner_lookup|
      Cache::BrowserChannels::ResponsesForPrefix.perform_async(site_banner_lookup[:prefix])
    end
  end
end
