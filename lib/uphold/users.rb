# typed: true

module Uphold
  class Users < Uphold::BaseClient
    include Uphold::Types
    extend T::Sig

    class ResultError < StandardError; end

    # https://uphold.com/en/developer/api/documentation/#get-user
    sig { returns(T.any(UpholdUser, Faraday::Response)) }
    def get
      result = request_and_return(:get, "/v0/me", UpholdUser)

      case result
      when UpholdUser, Faraday::Response
        result
      when Array, T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end
  end
end
