# typed: true

module Rewards
  class Parameters < Rewards::Client
    include Rewards::Types

    class ResultError < StandardError; end

    def get_parameters
      parse_response_to_struct(get(PATH + "parameters"), ParametersResponse)
    end

    def get_cached_parameters
      Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 5.minutes) do
        get_parameters
      end
    end

    # Returns either an error or the custodianRegions secton of the parameters response
    def fetch_allowed_regions(cached = true)
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
