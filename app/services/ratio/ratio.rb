# typed: true
# frozen_string_literal: true

module Ratio
  class Ratio < BaseApiClient
    PATH = "/v2/"
    RATES_CACHE_KEY = "rates_cache"

    def relative
      # https://ratios.rewards.brave.com/v2/relative/provider/coingecko/bat/usd,eur/1d
      return JSON.parse(relative_mock_response) if Rails.configuration.pub_secrets[:bat_ratios_token].blank?
      response = get("/v2/relative/provider/coingecko/bat/usd,eur,btc,eth,gbp/live")

      JSON.parse(response.body)
    end

    def self.relative_cached
      # Cache the ratios every minute. Rates are used for display purposes only.
      Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 10.minutes) do
        Ratio.new.relative
      end
    end

    def api_base_uri
      Rails.configuration.pub_secrets[:bat_ratios_url]
    end

    def api_authorization_header
      "Bearer #{Rails.configuration.pub_secrets[:bat_ratios_token]}"
    end

    def relative_mock_response
      <<-JSON
      {
        "payload": {
          "bat": {
            "btc": 0.00001002,
            "btc_timeframe_change": 0,
            "eth":0.00013862,
            "eth_timeframe_change":0,
            "eur":0.15505,
            "eur_timeframe_change":0,
            "gbp":0.137403,
            "gbp_timeframe_change":0,
            "usd":0.165864,
            "usd_timeframe_change":0.69631645135915
          }
        },
        "lastUpdated":"2022-12-30T19:24:23.405184202Z"
      }
      JSON
    end
  end
end
