require "concerns/two_factor_auth"

class U2fAuthenticationsController < ApplicationController
  include TwoFactorAuth

  def create
    u2f_response = U2F::SignResponse.load_from_json(params[:u2f_response])
    publisher = pending_2fa_current_publisher

    registration = publisher.u2f_registrations.find_by(key_handle: u2f_response.key_handle)

    begin
      u2f.authenticate!(
        session[:challenge],
        u2f_response,
        Base64.decode64(registration.public_key),
        registration.counter
      )
    rescue U2F::Error => e
      Rails.logger.debug("U2F::Error! #{e}")
      redirect_to two_factor_authentications_path
      return
    ensure
      session.delete(:challenge)
    end

    registration.update!(counter: u2f_response.counter)
    session.delete(:pending_2fa_current_publisher_id)

    sign_in(:publisher, publisher)
    redirect_to publisher_next_step_path(publisher)
  end
end
