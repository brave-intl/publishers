# typed: true

module Rewards
  class Parameters < Rewards::Client
    include Rewards::Types
    extend T::Sig

    class ResultError < StandardError; end

    sig { returns(T.any(ParametersResponse, Faraday::Response)) }
    def get_parameters
      response = Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 1.day) do
        get(PATH + "parameters") 
      end

      result = parse_response_to_struct(response, ParametersResponse)

      case result
      when ParametersResponse, Faraday::Response
        result
      when Array, T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end
  end
end
