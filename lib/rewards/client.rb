# typed: true
# frozen_string_literal: true

module Rewards
  class BaseClient < BaseApiClient
    extend T::Sig

    PATH = "/v1/"
    RATES_CACHE_KEY = "rewards_cache"

    private

    sig(:final) { returns(String) }
    def api_base_uri
      Rails.application.secrets[:rewards_url]
    end
  end
end
