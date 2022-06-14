#typed: false

module Uphold
  class Cards < Uphold::BaseClient
    include Uphold::Types

    # https://uphold.com/en/developer/api/documentation/#list-cards 
    def list(query = nil)
       request_and_return(:get, "/v0/me/cards", UpholdCard, query: query)
    end

    # https://uphold.com/en/developer/api/documentation/#get-card-details
    def get(id)
      request_and_return(:get, "/v0/me/cards/#{id}", UpholdCard)
    end

    # https://uphold.com/en/developer/api/documentation/#list-card-addresses
    sig { params(id: String).returns(T.any(UpholdCardAddresses, Faraday::Response)) }
    def list_addresses(id)
      request_and_return(:get, "/v0/me/cards/#{id}/addresses", UpholdCardAddress)
    end

    # https://uphold.com/en/developer/api/documentation/#create-card
    def create(label:, currency:, settings:)
      request_and_return(:post, "/v0/me/cards", UpholdCard, payload: {label: label, currency: currency, settings: settings} )
    end
  end
end
