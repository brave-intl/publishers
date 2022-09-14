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
  end
end
