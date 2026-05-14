# typed: ignore

class Api::Nextv1::TwoFactorAuthenticationsController < Api::Nextv1::BaseController
  include PublishersHelper
  include PendingActions

  before_action :require_pending_action

  # GET /api/nextv1/two_factor_authentications
  # Returns 2FA challenge options (WebAuthn get options if U2F enabled)
  def index
    publisher = saved_pending_action.publisher

    response_data = {
      u2f_enabled: u2f_enabled?(publisher),
      totp_enabled: totp_enabled?(publisher)
    }

    if u2f_enabled?(publisher)
      get_options = WebAuthn::Credential.options_for_get(
        allow: publisher.u2f_registrations.map(&:key_handle),
        extensions: {appid: Rails.configuration.pub_secrets[:creators_full_host]}
      )
      session[:current_authentication] = {
        challenge: get_options.challenge,
        username: publisher.email
      }
      response_data[:webauthn_options] = get_options
    end

    render(json: response_data.to_json, status: 200)
  end

  private

  def require_pending_action
    unless session[:pending_action]
      render(json: {error: "no_pending_action"}, status: 400)
    end
  end
end
