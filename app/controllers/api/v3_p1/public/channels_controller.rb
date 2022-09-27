# typed: true

class Api::V3P1::Public::ChannelsController < Api::V3::Public::BaseController
  include BrowserChannelsDynoCaching
  @@cached_payload = nil
  REDIS_KEY = "browser_channels_json_v3_p1".freeze
  REDIS_THUNDERING_HERD_KEY = "browser_channels_json_v3_p1_th".freeze

  def dyno_expiration_key
    "browser_v3_p1_channels_expiration:#{ENV["DYNO"]}"
  end
end
