module Uphold
  class Cards < Uphold::BaseClient
    include Uphold::Types

    # https://uphold.com/en/developer/api/documentation/#list-cards 
    sig { params(query: T.nilable(String)).returns(UpholdCards) }
    def list(query = nil)
      request_and_return(:get, "/v0/me/cards", UpholdCard, query: query)
    end

    # https://uphold.com/en/developer/api/documentation/#get-card-details
    sig { params(id: String).returns(UpholdCard) }
    def get(id)
      request_and_return(:get, "/v0/me/cards/#{id}", UpholdCard)
    end

    # https://uphold.com/en/developer/api/documentation/#create-card
    sig { params(label: String, currency: String, settings: T::Hash[Symbol, T::Boolean]).returns(UpholdCard) }
    def create(label:, currency:, settings:)
      request_and_return(:post, "/v0/me/cards", UpholdCard, payload: {label: label, currency: currency, settings: settings} )
    end
  end
end
