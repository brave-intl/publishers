module Payment
  class Client < BaseApiClient
    def initialize(params = {})
    end

    def key
      @key ||= Payment::Models::Key.new
    end

    private

    def perform_offline?
      Rails.application.secrets[:api_paymen_base_uri].blank?
      false
    end

    def api_base_uri
      Rails.application.secrets[:api_payment_base_uri]
      'http://localhost:3335/'
    end

    def api_authorization_header
      "Bearer #{Rails.application.secrets[:api_promo_key]}"
      "Bearer foobarfoobar"
    end
  end
end
