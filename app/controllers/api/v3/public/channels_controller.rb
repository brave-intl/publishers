require 'sentry-raven'

class Api::V3::Public::ChannelsController < Api::V3::Public::BaseController
  include BrowserChannelsDynoCaching
  @@cached_payload = nil
  REDIS_KEY = 'browser_channels_json_v3'.freeze

  def totals
    statistical_totals_json = Rails.cache.fetch(CacheBrowserChannelsJsonJobV3::TOTALS_CACHE_KEY, race_condition_ttl: 30)
    render(json: statistical_totals_json, status: 200)
  end

  private

  def dyno_expiration_key
    "browser_v3_channels_expiration:#{ENV['DYNO']}"
  end
end
