class CacheBrowserChannelsJsonJob < ApplicationJob
  queue_as :heavy

  MAX_RETRY = 10

  def perform
    channels_json = JsonBuilders::ChannelsJsonBuilder.new("v1").build
    retry_count = 0
    result = nil

    loop do
      result = Rails.cache.write('browser_channels_json', channels_json)
      break if result || retry_count > MAX_RETRY

      retry_count += 1
      Rails.logger.info("CacheBrowserChannelsJsonJob could not write to Redis result: #{result}. Retrying: #{retry_count}/#{MAX_RETRY}")
    end

    if result
      Rails.logger.info("CacheBrowserChannelsJsonJob updated the cached browser channels json.")
    else
      SlackMessenger.new(message: "🚨 CacheBrowserChannelsJsonJob could not update the channels JSON. @publishers-team  🚨", channel: SlackMessenger::ALERTS)
      Rails.logger.info("CacheBrowserChannelsJsonJob could not update the channels JSON.")
    end
  end
end
