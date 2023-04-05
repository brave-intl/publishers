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
      parameters.custodianRegions
    rescue => error
      LogException.perform(parameters)
      LogException.perform(error)
      fallback
      # raise StandardError.new("Could not load allowed regions")
    end

    def fallback
      {uphold: {allow: ["AD", "AU", "AR", "AT", "BE", "BR", "BS", "BZ", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DK", "EC", "EE", "FI", "FR", "GD", "GT", "GR", "HK", "HN", "HU", "IE", "IS", "IT", "JM", "KY", "LI", "LT", "LV", "LU", "MC", "MT", "MX", "NI", "NO", "NZ", "PE", "PL", "PT", "PY", "SG", "TR", "UY", "ES", "SE", "GB", "US", "UM", "ZA"], block: []}, gemini: {allow: ["US"], block: []}, bitflyer: {allow: ["JP"], block: []}}
    end
  end
end
