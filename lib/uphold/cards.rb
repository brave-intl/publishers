# typed: true

module Uphold
  class Cards < Uphold::BaseClient
    extend T::Sig
    include Uphold::Types

    class ResultError < StandardError; end

    # https://uphold.com/en/developer/api/documentation/#list-cards
    sig { params(query: T.nilable(String)).returns(T.any(UpholdCards, Faraday::Response)) }
    def list(query = nil)
      result = request_and_return(:get, "/v0/me/cards", UpholdCard, query: query)

      case result
      when Array
        T.cast(result, UpholdCards)
      when Faraday::Response
        result
      when T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end

    # https://uphold.com/en/developer/api/documentation/#get-card-details
    sig { params(id: String).returns(T.any(UpholdCard, Faraday::Response)) }
    def get(id)
      result = request_and_return(:get, "/v0/me/cards/#{id}", UpholdCard)

      case result
      when UpholdCard, Faraday::Response
        result
      when Array, T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end

    # https://uphold.com/en/developer/api/documentation/#list-card-addresses
    sig { params(id: String).returns(T.any(UpholdCardAddresses, Faraday::Response)) }
    def list_addresses(id)
      result = request_and_return(:get, "/v0/me/cards/#{id}/addresses", UpholdCardAddress)

      case result
      when Array
        T.cast(result, UpholdCardAddresses)
      when Faraday::Response
        result
      when T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end

    # https://uphold.com/en/developer/api/documentation/#create-card
    sig { params(label: String, currency: String, settings: T::Hash[T.any(String, Symbol), T.untyped]).returns(T.any(UpholdCard, Faraday::Response)) }
    def create(label:, currency:, settings:)
      result = request_and_return(:post, "/v0/me/cards", UpholdCard, payload: {label: label, currency: currency, settings: settings})
      case result
      when UpholdCard, Faraday::Response
        result
      when Array, T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end
  end
end
