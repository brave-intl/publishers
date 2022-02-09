# typed: true
# frozen_string_literal: true

module TwoFactorAuth
  class WebauthnVerifyService
    def self.build
      new
    end

    def call(publisher:, webauthn_u2f_response:, domain:, session:)
      client_json_wrapper = JSON.parse(webauthn_u2f_response)
      client_json_response = client_json_wrapper["response"]
      response_id = client_json_wrapper["id"]

      registration = publisher.u2f_registrations.find_by(key_handle: response_id)

      # For future: To determine if this is a U2F request, you can use passed values from the client like:
      # client_json_wrapper[:clientExtensionResults][:appid] is set if is
      # Or you can check the DB, which we do below

      assertion_response = WebAuthn::AuthenticatorAssertionResponse.new(
        user_handle: registration.key_handle,
        authenticator_data: Base64.urlsafe_decode64(client_json_response["authenticatorData"]),
        client_data_json: Base64.urlsafe_decode64(client_json_response["clientDataJSON"]),
        signature: Base64.urlsafe_decode64(client_json_response["signature"])
      )

      begin
        if registration.u2f? # old registration format
          assertion_response.verify(
            Base64.urlsafe_decode64(session[:current_authentication][:challenge]),
            domain,
            public_key: Base64.urlsafe_decode64(registration.public_key),
            sign_count: registration.counter,
            rp_id: domain
          )
        else
          assertion_response.verify(
            Base64.urlsafe_decode64(session[:current_authentication][:challenge]),
            domain,
            public_key: Base64.urlsafe_decode64(registration.public_key),
            sign_count: registration.counter
          )
        end
      rescue WebAuthn::VerificationError => e
        Rails.logger.debug("WebAuthn::Error! #{e}")
        return OpenStruct.new(success?: false, result: nil, errors: [e])
      ensure
        session.delete(:current_authentication)
      end

      counter = assertion_response.authenticator_data.sign_count
      if registration.counter >= counter
        Rails.logger.debug("Credential replay detected!")
        return OpenStruct.new(success?: false, result: nil, errors: [StandardError.new("Cannot authenticate.")])
      end
      registration.update!(counter: counter)
      session.delete(:pending_2fa_current_publisher_id)

      OpenStruct.new(success?: true, result: nil, errors: nil)
    end
  end
end
