class CacheBrowserChannelsJsonJobV2 < ApplicationJob
  queue_as :heavy

  MAX_RETRY = 10
  LAST_WRITTEN_AT_KEY = "CacheBrowserChannelsJsonJobV2_last_written_at".freeze

  def perform
    last_written_at = Rails.cache.fetch(LAST_WRITTEN_AT_KEY)
    return if last_written_at.present? && last_written_at > 2.hours.ago
    channels_json = JsonBuilders::ChannelsJsonBuilderV2.new.build
    retry_count = 0
    result = nil

    loop do
      result = Rails.cache.write(Api::V2::Public::ChannelsController::REDIS_KEY, channels_json)
      break if result || retry_count > MAX_RETRY

      retry_count += 1
      Rails.logger.info("CacheBrowserChannelsJsonJob V2 could not write to Redis result: #{result}. Retrying: #{retry_count}/#{MAX_RETRY}")
    end

    if result
      Rails.cache.write(LAST_WRITTEN_AT_KEY, Time.now)
      Rails.logger.info("CacheBrowserChannelsJsonJob V2 updated the cached browser channels json.")
    else
      SlackMessenger.new(message: "🚨 CacheBrowserChannelsJsonJob V2 could not update the channels JSON. @publishers-team  🚨", channel: SlackMessenger::ALERTS)
      Rails.logger.info("CacheBrowserChannelsJsonJob V2 could not update the channels JSON.")
    end
  end
end
