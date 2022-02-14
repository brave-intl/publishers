# typed: ignore
require "concerns/two_factor_registration"
require "concerns/logout"

class U2fRegistrationsController < ApplicationController
  include Logout
  include TwoFactorRegistration
  extend T::Helpers

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
    challenge = session.delete(:creation_challenge)
    name = params.require(:u2f_registration).permit(:name)[:name]

    result = TwoFactorAuth::WebauthnRegistrationService.build.call(publisher: current_publisher,
      webauthn_response: params[:webauthn_response],
      name: name,
      challenge: challenge)

    case result
    when BSuccess
      logout_everybody_else!
      handle_redirect_after_2fa_registration
    when BFailure
      redirect_to new_u2f_registration_path && return
    else
      T.absurd(result)
    end
  end

  def destroy
    u2f_registration = current_publisher.u2f_registrations.find(params[:id])
    u2f_registration.destroy

    redirect_to security_publishers_path
  end
end
