# typed: ignore

require "concerns/two_factor_registration"
require "concerns/logout"

class TotpRegistrationsController < ApplicationController
  helper QrCodeHelper
  include Logout
  include TwoFactorRegistration
  include PendingActions

  before_action :authenticate_publisher!

  def new
    @totp_registration = TotpRegistration.new secret: ROTP::Base32.random_base32
    @provisioning_url = @totp_registration.totp.provisioning_uri(current_publisher.email)
  end

  class AddTOTP < StepUpAction
    call do |publisher_id, password, totp_registration_params|
      current_publisher = Publisher.find(publisher_id)
      totp_registration = TotpRegistration.new totp_registration_params

      if totp_registration.totp.verify(password, drift_ahead: 60, drift_behind: 60, at: Time.now - 30)
        current_publisher.totp_registration.destroy! if current_publisher.totp_registration.present?
        totp_registration.publisher = current_publisher
        totp_registration.save!

        logout_everybody_else!(current_publisher)

        handle_redirect_after_2fa_registration
      else
        Rails.logger.info "ROTP::TOTP! Failed to verify unsaved #{totp_registration} for publisher #{current_publisher.owner_identifier} with password '#{params[:totp_password]}'"
        flash[:alert] = t("shared.invalid_totp")
        redirect_to new_totp_registration_path
      end
    end
  end

  def create
    AddTOTP.new(current_publisher.id, params[:totp_password], totp_registration_params.to_h).step_up! self
  end

  class RemoveTOTP < StepUpAction
    call do |publisher_id|
      current_publisher = Publisher.find(publisher_id)
      current_publisher.totp_registration.destroy! if current_publisher.totp_registration.present?
      redirect_to security_publishers_path
    end
  end

  def destroy
    RemoveTOTP.new(current_publisher.id).step_up! self
  end

  private

  def totp_registration_params
    params.require(:totp_registration).permit(:secret)
  end
end
