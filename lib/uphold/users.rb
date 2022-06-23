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

    sig { params(capability: String).returns(T.any(UpholdUserCapability, Faraday::Response)) }
    def get_capability(capability)
      result = request_and_return(:get, "/v0/me/capabilities/#{capability}", UpholdUserCapability)

      case result
      when UpholdUserCapability, Faraday::Response
        result
      when Array, T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end
  end
end
