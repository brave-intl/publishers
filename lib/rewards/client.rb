# typed: true
# frozen_string_literal: true

module Rewards
  class Client < BaseApiClient
    extend T::Sig

    PATH = "/v1/"
    RATES_CACHE_KEY = "rewards_cache"

    private

    sig(:final) { returns(String) }
    def api_base_uri
      "https://api.rewards.bravesoftware.com"
    end
  end
end
