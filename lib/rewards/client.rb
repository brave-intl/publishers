# typed: true
# frozen_string_literal: true

module Rewards
  class Client < BaseApiClient
    PATH = "/v1/"
    RATES_CACHE_KEY = "rewards_cache"

    private

    def api_base_uri
      Rails.application.credentials[:api_rewards_base_uri]
    end
  end
end
