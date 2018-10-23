# Registers infinity codes for a Brave admin
class PromoRegistrarUnattached < BaseApiClient
  include PromosHelper

  def initialize(number:, promo_id: active_promo_id, campaign: nil)
    @number = number
    @promo_id = promo_id
    @campaign
  end

  def perform
    return if @number <= 0
    return register_unattached_offline if perform_promo_offline?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/2/promo/referral_code/unattached?number=#{@number}")
    end

    promo_registrations = JSON.parse(response.body)
    promo_registrations.each do |promo_registration|
      PromoRegistration.create!(referral_code: promo_registration["referral_code"],
                                promo_id: active_promo_id,
                                kind: "unattached")
    end
  end

  def register_unattached_offline
    Rails.logger.info("PromoRegistrar #register_channel offline.")
    offline_referral_code
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end
end