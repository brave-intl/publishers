class Api::Nextv1::TotpRegistrationsController < Api::Nextv1::BaseController
  include QrCodeHelper
  def new
    @totp_registration = TotpRegistration.new secret: ROTP::Base32.random_base32
    @provisioning_url = @totp_registration.totp.provisioning_uri(current_publisher.email)

    response_data = {
      registration: @totp_registration,
      qr_code_svg: qr_code_svg(@provisioning_url)
    }

    render(json: response_data.to_json, status: 200)
  end
end
