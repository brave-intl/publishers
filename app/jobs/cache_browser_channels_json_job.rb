class CacheBrowserChannelsJsonJob < ApplicationJob
  queue_as :transactional

  def perform
    channels_json = JsonBuilders::ChannelsJsonBuilder.new.build
    Rails.cache.write('browser_channels_json', channels_json)
  end
end
