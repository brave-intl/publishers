# typed: true

module Rewards
  class Parameters < Rewards::BaseClient
    include Rewards::Types
    extend T::Sig

    class ResultError < StandardError; end

    sig { returns(T.any(ParametersResponse, Faraday::Response)) }
    def get
      response = get(PATH + "parameters")

      result = JSON.parse(response.body)

      case result
      when ParametersResponse, Faraday::Response
        result
      when Array, T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end

    def self.parameters_cached
      Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 1.day) do
        Rewards.new.parameters
      end
    end
  end
end
