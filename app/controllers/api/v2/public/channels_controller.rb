class Api::V2::Public::ChannelsController < Api::V2::Public::BaseController
  def channels
    channels_json = Rails.cache.fetch('browser_channels_json_v2', race_condition_ttl: 30) do
      require 'sentry-raven'
      Raven.capture_message("Failed to use redis cache for /api/public/channels V2, using DB instead.")
      channels_json = JsonBuilders::ChannelsJsonBuilderV2.new.build
    end
    render(json: channels_json, status: 200)
  end

  def totals
    render(json: Channel.statistical_totals, status: 200)
  end
end
