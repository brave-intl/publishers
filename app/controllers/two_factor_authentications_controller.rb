require "concerns/two_factor_auth"

class TwoFactorAuthenticationsController < ApplicationController
  include PublishersHelper
  include TwoFactorAuth

  def index
    @u2f_enabled = u2f_enabled?(pending_2fa_current_publisher)
    if !params[:request_totp] && @u2f_enabled
      challenge = u2f.challenge
      session[:challenge] = challenge
      @u2f_authentication_attempt = {
        app_id: u2f.app_id,
        challenge: challenge,
        sign_requests: u2f.authentication_requests(
          pending_2fa_current_publisher.u2f_registrations.map(&:key_handle)
        )
      }
    end

    @totp_enabled = totp_enabled?(pending_2fa_current_publisher)
  end

end
