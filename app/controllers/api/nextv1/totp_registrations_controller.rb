class Api::Nextv1::TotpRegistrationsController < Api::Nextv1::BaseController
  include QrCodeHelper
  include TwoFactorRegistration
  include PendingActions

  def new
    @totp_registration = TotpRegistration.new secret: ROTP::Base32.random_base32
    @provisioning_url = @totp_registration.totp.provisioning_uri(current_publisher.email)

    response_data = {
      registration: @totp_registration,
      qr_code_svg: qr_code_svg(@provisioning_url)
    }

    render(json: response_data.to_json, status: 200)
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

       render(json: {}, status: 200)
      else
       render(json: {errors: totp_registration.errors}, status: 400)
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
    end
  end

  def destroy
    RemoveTOTP.new(current_publisher.id).step_up! self

    render(json: {}, status: 200)
  end

  private

  def totp_registration_params
    params.require(:totp_registration).permit(:secret)
  end
end
