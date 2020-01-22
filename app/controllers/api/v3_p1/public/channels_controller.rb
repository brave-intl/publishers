require 'sentry-raven'

class Api::V3P1::Public::ChannelsController < Api::V3::Public::BaseController
  include BrowserChannelsDynoCaching
  @@cached_payload = nil
  REDIS_KEY = 'browser_channels_json_v3_p1'.freeze

  def dyno_expiration_key
    "browser_v3_channels_expiration:#{ENV['DYNO']}"
  end
end
