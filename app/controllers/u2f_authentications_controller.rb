# typed: ignore
require "concerns/two_factor_auth"

class U2fAuthenticationsController < ApplicationController
  include TwoFactorAuth

  def create
    publisher = pending_2fa_current_publisher
    client_json_wrapper = JSON.parse(params[:webauthn_u2f_response])
    client_json_response = client_json_wrapper["response"]
    domain = request.base_url
    response_id = client_json_wrapper["id"]

    registration = publisher.u2f_registrations.find_by(key_handle: response_id)

    # For future: To determine if this is a U2F request:
    # client_json_wrapper[:clientExtensionResults][:appid] is set if is

    assertion_response = WebAuthn::AuthenticatorAssertionResponse.new(
      user_handle: registration.key_handle,
      authenticator_data: Base64.urlsafe_decode64(client_json_response["authenticatorData"]),
      client_data_json: Base64.urlsafe_decode64(client_json_response["clientDataJSON"]),
      signature: Base64.urlsafe_decode64(client_json_response["signature"])
    )

    begin
      assertion_response.verify(
        Base64.urlsafe_decode64(session[:current_authentication][:challenge]),
        domain,
        public_key: Base64.urlsafe_decode64(registration.public_key),
        sign_count: registration.counter,
        rp_id: domain
      )
    rescue WebAuthn::VerificationError => e
      Rails.logger.debug("WebAuthn::Error! #{e}")
      redirect_to two_factor_authentications_path
      return
    ensure
      session.delete(:current_authentication)
    end

    counter = assertion_response.authenticator_data.sign_count
    if registration.counter >= counter
      Rails.logger.debug("Credential replay detected!")
      redirect_to two_factor_authentications_path
      return
    end
    registration.update!(counter: counter)
    session.delete(:pending_2fa_current_publisher_id)

    sign_in(:publisher, publisher)
    redirect_to publisher_next_step_path(publisher)
  end
end
