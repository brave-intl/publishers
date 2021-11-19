# typed: false
class Api::V2::Public::ChannelsController < Api::V2::Public::BaseController
  include BrowserChannelsDynoCaching
  @@cached_payload = nil
  REDIS_KEY = "browser_channels_json_v2".freeze
  REDIS_THUNDERING_HERD_KEY = "browser_channels_json_v2_th".freeze

  def totals
    render(json: Channel.statistical_totals, status: 200)
  end

  private

  def dyno_expiration_key
    "browser_v2_channels_expiration:#{ENV["DYNO"]}"
  end
end
