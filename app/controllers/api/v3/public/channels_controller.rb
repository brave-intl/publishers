# typed: ignore

class Api::V3::Public::ChannelsController < Api::V3::Public::BaseController
  include BrowserChannelsDynoCaching
  @@cached_payload = nil
  REDIS_KEY = "browser_channels_json_v3".freeze
  REDIS_THUNDERING_HERD_KEY = "browser_channels_json_v3_th".freeze

  def totals
    statistical_totals_json = Rails.cache.fetch(CacheBrowserChannelsJsonJobV3::TOTALS_CACHE_KEY, race_condition_ttl: 30)
    render(json: statistical_totals_json, status: 200)
  end

  # Takes an array of channel identifiers and retuns a dictionary of channel identifiers as keys and true/false as values
  def allowed_countries
    channels = params[:channel_ids].map do |id|
      {channel: Channel.find_by_channel_identifier(id), channel_identifier: id}
    end

    allowed_regions = Rewards::Parameters.new.fetch_allowed_regions

    response = {}
    channels.each do |channel_obj|
      publisher = channel_obj[:channel].publisher

      response[channel_obj[:channel_identifier]] = if publisher.uphold_connection.present?
        allowed_regions[:uphold][:allow].include?(publisher.uphold_connection.country)
      elsif publisher.gemini_connection.present?
        allowed_regions[:gemini][:allow].include?(publisher.gemini_connection.country)
      else
        publisher.bitflyer_connection.present?
      end
    end

    # is there any metadata we need here?
    render(json: response.to_json, status: 200)
  end

  private

  def dyno_expiration_key
    "browser_v3_channels_expiration:#{ENV["DYNO"]}"
  end
end
