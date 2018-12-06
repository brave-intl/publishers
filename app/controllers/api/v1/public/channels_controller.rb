class Api::V1::Public::ChannelsController < Api::V1::Public::BaseController
  def channels
    channels_json = Rails.cache.fetch('browser_channels_json', race_condition_ttl: 30) do
      require 'sentry-raven'
      Raven.capture_message("Failed to use redis cache for /api/public/channels, using DB instead.")
      channels_json = JsonBuilders::ChannelsJsonBuilder.new.build
    end
    render(json: channels_json, status: 200)
  end

  def totals
    render(
      json: {
        all_channels: Channel.verified.count,
        twitch: Channel.verified.twitch_channels.count,
        youtube:  Channel.verified.youtube_channels.count,
        site:  Channel.verified.site_channels.count
      },
      status: 200
    )
  end
end
