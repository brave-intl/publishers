# typed: true
# frozen_string_literal: true

module Rewards
  class Rewards < BaseApiClient
    PATH = "/v1/"
    RATES_CACHE_KEY = "rewards_cache"

    def parameters
      return JSON.parse(mock_response) if Rails.application.secrets[:rewards_url].blank?
      response = get(PATH + 'parameters')

      JSON.parse(response.body)
    end

    def self.parameters_cached
      Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 1.day) do
        Rewards.new.parameters
      end
    end

    def api_base_uri
      Rails.application.secrets[:rewards_url]
    end

    def mock_response
      <<-JSON
      {"payoutStatus":{"unverified":"complete","uphold":"complete","gemini":"complete","bitflyer":"complete"},"custodianRegions":{"uphold":{"allow":["AU","AT","BE","CA","CO","DK","FI","HK","IE","IT","NL","NO","PT","SG","ES","SE","GB","US"],"block":[]},"gemini":{"allow":["AU","AT","BE","CA","CO","DK","FI","HK","IE","IT","NL","NO","PT","SG","ES","SE","GB","US"],"block":[]},"bitflyer":{"allow":["JP"],"block":[]}},"batRate":0.367443,"autocontribute":{"choices":[1,2,3,5,7,10,20],"defaultChoice":1},"tips":{"defaultTipChoices":[1.25,5,10.5],"defaultMonthlyChoices":[1.25,5,10.5]}}
      JSON
    end
  end
end
