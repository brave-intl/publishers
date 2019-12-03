module Promo
  class Client < BaseApiClient
    def initialize(connection = nil, options = {})
      @connection = connection
    end

    def owner_state
      Promo::Models::OwnerState.new(connection)
    end

    private

    def perform_offline?
      Rails.application.secrets[:api_promo_base_uri].blank?
    end

    def api_base_uri
      Rails.application.secrets[:api_promo_base_uri]
    end

    def api_authorization_header
      "Bearer #{Rails.application.secrets[:api_promo_key]}"
    end
  end
end
