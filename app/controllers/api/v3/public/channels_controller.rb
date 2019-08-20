require 'sentry-raven'

class Api::V3::Public::ChannelsController < Api::V3::Public::BaseController
  def channels
    channels_json = Rails.cache.fetch('browser_channels_json_v3', race_condition_ttl: 30) do
      Raven.capture_message("Failed to use redis cache for /api/public/channels V3, using DB instead.")
      channels_json = JsonBuilders::ChannelsJsonBuilderV3.new.build
    end
    render(json: channels_json, status: 200)
  end

  def totals
    statistical_totals_json = Rails.cache.fetch(CacheBrowserChannelsJsonJobV3::TOTALS_CACHE_KEY, race_condition_ttl: 30)
    render(json: statistical_totals_json, status: 200)
  end
end
