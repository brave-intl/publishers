# Associates an installer type with a referral code
class Promo::RegistrationInstallerTypeSetter < BaseApiClient
  include PromosHelper

  def initialize(promo_registrations:, installer_type:)
    @promo_registrations = promo_registrations
    @referral_codes = promo_registrations.map { |promo_registration| promo_registration.referral_code }
    @installer_type = installer_type
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_promo_base_uri].blank?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/2/promo/referral/installerType")
      request.body = {"referralCodes" => @referral_codes, "installerType" => @installerType }.to_json
    end

    @promo_registrations.update_all(installer_type: @installer_type) if response.status == 200
  end

  def perform_offline
    true
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end
end