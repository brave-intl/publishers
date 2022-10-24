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
      Rails.application.secrets[:api_rewards_base_uri]
    end
  end
end
