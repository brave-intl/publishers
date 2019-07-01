class CacheBrowserChannelsJsonJobV2Whitelist < ApplicationJob
  queue_as :heavy

  MAX_RETRY = 10
  REDIS_KEY = "browser_channels_json_v2_whitelist"

  def perform
    channels_json = JsonBuilders::ChannelsJsonBuilderV2.new.build(whitelist: whitelist)
    retry_count = 0
    result = nil

    loop do
      result = Rails.cache.write(REDIS_KEY, channels_json)
      break if result || retry_count > MAX_RETRY

      retry_count += 1
      Rails.logger.info("CacheBrowserChannelsJsonJob V2 could not write to Redis result: #{result}. Retrying: #{retry_count}/#{MAX_RETRY}")
    end

    if result
      Rails.logger.info("CacheBrowserChannelsJsonJob V2 updated the cached browser channels json.")
    else
      SlackMessenger.new(message: "🚨 CacheBrowserChannelsJsonJob V2 could not update the channels JSON. @publishers-team  🚨", channel: SlackMessenger::ALERTS)
      Rails.logger.info("CacheBrowserChannelsJsonJob V2 could not update the channels JSON.")
    end
  end
end
