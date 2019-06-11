class Api::V2::Public::ChannelsController < Api::V2::Public::BaseController
    def channels
      # channels_json = Rails.cache.fetch('browser_channels_json', race_condition_ttl: 30) do
        require 'sentry-raven'
        Raven.capture_message("Failed to use redis cache for /api/public/channels, using DB instead.")
        channels_json = JsonBuilders::ChannelsJsonBuilder.new("v2").build
      # end
      render(json: channels_json, status: 200)
    end
  
    def totals
      render(json: Channel.statistical_totals, status: 200)
    end
  end
  