# typed: true

# Registers infinity codes for a Brave admin
class Promo::UnattachedRegistrar < BaseApiClient
  include PromosHelper

  def initialize(number:, promo_id: active_promo_id, campaign: nil, publisher: nil, description: nil)
    @number = number
    @promo_id = promo_id
    @campaign = campaign
    @publisher = publisher
    @description = description
  end

  def perform
    return if @number <= 0
    return perform_offline if perform_promo_offline?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/2/promo/referral_code/unattached?number=#{@number}")
    end

    promo_registrations = JSON.parse(response.body)
    promo_registrations.each do |promo_registration|
      PromoRegistration.create!(
        referral_code: promo_registration["referral_code"],
        promo_id: @promo_id,
        kind: PromoRegistration::UNATTACHED,
        promo_campaign: @campaign,
        publisher: @publisher,
        description: @description
      )
    end
  end

  def perform_offline
    @number.times do
      PromoRegistration.create!(
        referral_code: offline_referral_code,
        promo_id: @promo_id,
        kind: PromoRegistration::UNATTACHED,
        promo_campaign: @campaign,
        publisher: @publisher,
        description: @description
      )
    end
  end

  private

  def proxy_url
    nil
  end

  def api_base_uri
    Rails.configuration.pub_secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.configuration.pub_secrets[:api_promo_key]}"
  end
end
