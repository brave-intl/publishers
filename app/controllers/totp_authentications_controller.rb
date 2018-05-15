require "concerns/two_factor_auth"

class TotpAuthenticationsController < ApplicationController
  include TwoFactorAuth

  def create
    publisher = pending_2fa_current_publisher
    totp_registration = pending_2fa_current_publisher.totp_registration

    verified_at_timestamp = totp_registration.totp.verify_with_drift_and_prior(
      params[:totp_password],
      60,
      totp_registration.last_logged_in_at,
      Time.now - 30
    )
    if verified_at_timestamp
      totp_registration.update_attributes!({ last_logged_in_at: Time.at(verified_at_timestamp) })
      session.delete(:pending_2fa_current_publisher_id)
      sign_in(:publisher, publisher)

      redirect_to publisher_next_step_path(publisher)
    else
      flash[:alert] = t("shared.invalid_totp")
      redirect_to two_factor_authentications_path(request_totp: true)
    end
  end
end
