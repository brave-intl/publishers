# typed: true

module Promo
  class Client < BaseApiClient
    def initialize(connection = nil, options = {})
      @connection = connection
    end

    def owner_state
      @owner_state ||= Promo::Models::OwnerState.new(connection)
    end

    def reporting
      @reporting ||= Promo::Models::Reporting.new(connection)
    end

    def peer_to_peer_registration
      @peer_to_peer_registration ||= Promo::Models::PeerToPeerRegistration.new(connection)
    end

    private

    def perform_offline?
      Rails.configuration.pub_secrets[:api_promo_base_uri].blank?
    end

    def api_base_uri
      Rails.configuration.pub_secrets[:api_promo_base_uri]
    end

    def api_authorization_header
      "Bearer #{Rails.configuration.pub_secrets[:api_promo_key]}"
    end

    def proxy_url
      nil
    end
  end
end
