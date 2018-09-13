class CacheVerifiedChannelsJsonJob < ApplicationJob
  queue_as :transactional

  def perform
    channels_json = JsonBuilders::VerifiedChannelsJsonBuilder.new.build
    Rails.cache.write('verified_channels_json', channels_json)
    Rails.logger.info("CacheVerifiedChannelsJsonJob updated the verified_channels_json.")
  end
end
