# typed: true

module Gemini
  class Setting < BaseApiClient
    include Initializable

    # For more information about how these URI templates are structured read the explaination in the RFC
    # https://github.com/sporkmonger/addressable
    # https://www.rfc-editor.org/rfc/rfc6570.txt
    PATH = Addressable::Template.new("/v1/account/settings{/segments*}{?query*}")

    attr_accessor :token, :result, :payment_currency

    # Public: Finds the accounts that are authorized with a token
    #
    # token - An access token obtained through the OAuth flow
    #
    # Returns a Gemini::Account
    def self.set_payment_currency(token:, payment_currency:)
      Setting.new(token: token).set_payment_currency(payment_currency: payment_currency)
    end

    def set_payment_currency(payment_currency:)
      payload = {payment_currency: payment_currency}
      headers = {"X-GEMINI-PAYLOAD" => Base64.encode64(payload.to_json)}
      response = post(PATH.expand(segments: "paymentCurrency"), {}, api_authorization_header, headers)

      Gemini::Setting.new(JSON.parse(response.body))
    end

    def api_base_uri
      Gemini.api_base_uri
    end

    def api_authorization_header
      "Bearer #{token}"
    end
  end
end
