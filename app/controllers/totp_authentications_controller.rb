# typed: ignore

class TotpAuthenticationsController < ApplicationController
  include PubTwoFactorAuth
  include Logout
  include TwoFactorRegistration
  include PendingActions

  def create
    pending_action = saved_pending_action
    totp_registration = pending_action.publisher.totp_registration

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
      flash[:alert] = t("shared.invalid_totp")
      redirect_to two_factor_authentications_path(request_totp: true)
    end
  end
end
