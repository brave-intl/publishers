# typed: ignore
require "concerns/two_factor_registration"
require "concerns/logout"

class U2fRegistrationsController < ApplicationController
  include Logout
  include TwoFactorRegistration

  before_action :authenticate_publisher!

  def new
    @u2f_registration = U2fRegistration.new
    publisher = current_publisher

    @webauthn_options = WebAuthn::Credential.options_for_create(
      user: {id: publisher.id, name: publisher.email},
      exclude: publisher.u2f_registrations.map { |c| c.key_handle }.compact
    )

    session[:creation_challenge] = @webauthn_options.challenge
  end

  def create
    response = JSON.parse(params[:webauthn_response])

    challenge = session.delete(:creation_challenge)
    credential = WebAuthn::Credential.from_create(response)

    begin
      credential.verify(challenge)
    rescue WebAuthn::Error => e
      Rails.logger.debug("Webauthn::Error! #{e}")
      redirect_to new_u2f_registration_path
      return
    end

    permitted = params.require(:u2f_registration).permit(:name)

    current_publisher.u2f_registrations.create!(
      permitted.merge({
        key_handle: credential.id,
        public_key: credential.public_key,
        counter: credential.sign_count,
        name: permitted[:name],
        format: U2fRegistration.formats[:webauthn]
      })
    )

    logout_everybody_else!
    handle_redirect_after_2fa_registration
  end

  def destroy
    u2f_registration = current_publisher.u2f_registrations.find(params[:id])
    u2f_registration.destroy

    redirect_to security_publishers_path
  end
end
