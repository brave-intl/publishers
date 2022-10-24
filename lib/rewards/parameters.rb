# typed: true

module Rewards
  class Parameters < Rewards::Client
    include Rewards::Types
    extend T::Sig

    class ResultError < StandardError; end

    sig { returns(T.any(ParametersResponse, Faraday::Response)) }
    def get_parameters
      T.let(parse_response_to_struct(get(PATH + "parameters"), ParametersResponse), T.any(ParametersResponse, Faraday::Response))
    end

    sig { returns(T.any(ParametersResponse, Faraday::Response)) }
    def get_cached_parameters
      Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 12.hours) do
        get_parameters
      end
    end

    # Returns either an error or the custodianRegions secton of the parameters response
    sig { params(cached: T::Boolean).returns(T.any(T::Hash[T.any(String, Symbol), T::Hash[T.any(String, Symbol), T::Array[T.nilable(String)]]], StandardError)) }
    def fetch_allowed_regions(cached = false)
      parameters = cached ? get_cached_parameters : get_parameters

      case parameters
      when Rewards::Types::ParametersResponse
        parameters.custodianRegions
      else
        LogException.perform(parameters)
        raise StandardError.new("Could not load allowed regions")
      end
    end
  end
end
