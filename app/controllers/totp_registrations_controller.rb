require "concerns/two_factor_registration"

class TotpRegistrationsController < ApplicationController
  helper QrCodeHelper
  include TwoFactorRegistration

  before_action :authenticate_publisher!

  def new
    @totp_registration = TotpRegistration.new secret: ROTP::Base32.random_base32
    @provisioning_url = @totp_registration.totp.provisioning_uri(current_publisher.email)
  end

  def create
    totp_registration = TotpRegistration.new totp_registration_params

    if totp_registration.totp.verify_with_drift(params[:totp_password], 60, Time.now - 30)
      current_publisher.totp_registration.destroy! if current_publisher.totp_registration.present?
      totp_registration.publisher = current_publisher
      totp_registration.save!

      handle_redirect_after_2fa_registration
    else
      Rails.logger.info "ROTP::TOTP! Failed to verify unsaved #{totp_registration} for publisher #{current_publisher} with password '#{params[:totp_password]}'"
      flash[:alert] = t("shared.invalid_totp")
      redirect_to new_totp_registration_path
    end
  end

  def destroy
    current_publisher.totp_registration.destroy! if current_publisher.totp_registration.present?
    redirect_to two_factor_registrations_path
  end

  private

  def totp_registration_params
    params.require(:totp_registration).permit(:secret)
  end

end
