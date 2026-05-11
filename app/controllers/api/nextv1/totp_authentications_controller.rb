# typed: ignore

class Api::Nextv1::TotpAuthenticationsController < Api::Nextv1::BaseController
  include PublishersHelper
  include PendingActions

  before_action :require_pending_action

  # POST /api/nextv1/totp_authentications
  # Verify TOTP code and execute pending step-up action
  def create
    pending_action = saved_pending_action
    totp_registration = pending_action.publisher.totp_registration

    unless totp_registration
      render(json: {error: "totp_not_enabled"}, status: 400) && return
    end

    verified_at_timestamp = totp_registration.totp.verify(
      params[:totp_password],
      drift_ahead: 60,
      drift_behind: 60,
      after: totp_registration.last_logged_in_at,
      at: Time.now - 30
    )

    if verified_at_timestamp
      totp_registration.update!(last_logged_in_at: Time.at(verified_at_timestamp))
      pending_action.execute! self
    else
      render(json: {error: "invalid_totp"}, status: 401)
    end
  end

  private

  def require_pending_action
    unless session[:pending_action]
      render(json: {error: "no_pending_action"}, status: 400)
    end
  end
end
