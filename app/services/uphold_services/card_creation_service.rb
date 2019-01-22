# Requests eyeshade to create an Uphold currency card
module UpholdServices
  class CardCreationService < BaseApiClient
    def initialize(publisher:, currency_code:)
      @publisher = publisher
      @currency_code = currency_code || publisher.default_currency
    end

    def perform
      return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
      response = connection.post do |request|
        request.headers["Authorization"] = api_authorization_header
        request.headers["Content-Type"] = "application/json"
        request.body = {
          "currency": @currency_code,
          "label": "Brave Rewards"
        }.to_json
        request.url("/v3/owners/#{URI.escape(@publisher.owner_identifier)}/wallet/card")
      end

      response
    rescue Faraday::Error => e
      Rails.logger.error("UpholdServices::CardCreationService #perform error: #{e}")
      nil
    end

    def perform_offline
      Rails.logger.info("PublisherCardCreator")
      true
    end

    private

    def api_base_uri
      Rails.application.secrets[:api_eyeshade_base_uri]
    end

    def api_authorization_header
      "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
    end
  end
end
