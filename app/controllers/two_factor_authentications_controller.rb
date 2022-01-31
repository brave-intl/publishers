# typed: ignore
require "concerns/two_factor_auth"

class TwoFactorAuthenticationsController < ApplicationController
  include PublishersHelper
  include TwoFactorAuth

  def index
    @u2f_enabled = u2f_enabled?(pending_2fa_current_publisher)
    @removal = pending_2fa_current_publisher.two_factor_authentication_removal

    if !params[:request_totp] && @u2f_enabled
      get_options = WebAuthn::Credential.options_for_get(allow: pending_2fa_current_publisher.u2f_registrations.map(&:key_handle),
        extensions: {appid: request.base_url})
      session[:current_authentication] = {challenge: get_options.challenge, username: pending_2fa_current_publisher.email}
      @webauthn_u2f_backwards_compat_authentication_attempt = get_options
    end

    @totp_enabled = totp_enabled?(pending_2fa_current_publisher)
  end
end
