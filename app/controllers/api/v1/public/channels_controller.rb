class Api::V1::Public::ChannelsController < Api::V1::Public::BaseController
  include BrowserChannelsDynoCaching
  @@cached_payload ||= nil
  REDIS_KEY = 'browser_channels_json'.freeze

  def totals
    render(json: Channel.statistical_totals, status: 200)
  end

  private

  def dyno_expiration_key
    "browser_v1_channels_expiration:#{ENV['DYNO']}"
  end
end
