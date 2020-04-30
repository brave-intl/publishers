class Cache::BrowserChannels::Main
  include Sidekiq::Worker
  sidekiq_options queue: :scheduler, retry: false

  LAST_RAN_AT_KEY = "cache_browser_channels_main_last_ran_at".freeze
  RESPONSES_PREFIX_LENGTH = 3
  def perform
    previous_run = Rails.cache.fetch(LAST_RAN_AT_KEY)
    return if previous_run.present? && previous_run.to_time >= 2.hours.ago
    Cache::BrowserChannels::PrefixList.perform_async
    sql = "SELECT DISTINCT SUBSTRING(sha2_base16, 1, #{RESPONSES_PREFIX_LENGTH}) as prefix FROM site_banner_lookups"
    sql += " WHERE wallet_status != 0"
    sql += " AND updated_at >= '#{(previous_run.to_time - 3.minutes).to_s}'" if previous_run.present?
    sql += " ORDER BY prefix desc"
    result = ActiveRecord::Base.connection.execute(sql)
    result.each do |site_banner_lookup|
      Cache::BrowserChannels::ResponsesForPrefix.perform_async(site_banner_lookup[:prefix])
    end
    Rails.cache.write(LAST_RAN_AT_KEY, Time.now.to_s)
  end
end
