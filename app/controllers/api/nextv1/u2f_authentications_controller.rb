# typed: ignore

class Api::Nextv1::U2fAuthenticationsController < Api::Nextv1::BaseController
  include PublishersHelper
  include PendingActions

  before_action :require_pending_action

  # POST /api/nextv1/u2f_authentications
  # Verify WebAuthn/U2F assertion and execute pending step-up action
  def create
    pending_action = saved_pending_action
    publisher = pending_action.publisher
    domain = Rails.configuration.pub_secrets[:creators_full_host]

    result = TwoFactorAuth::WebauthnVerifyService.build.call(
      publisher: publisher,
      webauthn_u2f_response: params[:webauthn_u2f_response],
      domain: domain,
      session: session
    )

    case result
    when ::BSuccess
      pending_action.execute! self
    when ::BFailure
      render(json: {error: "invalid_u2f"}, status: 401)
    else
      raise result
    end
  end

  private

  def require_pending_action
    unless session[:pending_action]
      render(json: {error: "no_pending_action"}, status: 400)
    end
  end
end
