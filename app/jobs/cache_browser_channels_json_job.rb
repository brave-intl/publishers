class CacheBrowserChannelsJsonJob < ApplicationJob
  queue_as :heavy

  def perform
    channels_json = JsonBuilders::ChannelsJsonBuilder.new.build
    Rails.cache.write('browser_channels_json', channels_json)
    Rails.logger.info("CacheBrowserChannelsJsonJob updated the cached browser channels json.")
  end
end
