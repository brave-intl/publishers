# !! important, We are using UNATTACHED type for now until we move to polymorphic codes. 
class Promo::OwnerRegistrar < BaseApiClient
  include PromosHelper

  def initialize(number:, publisher_id:, promo_campaign_id:, description:, promo_id: active_promo_id)
    @number = number
    @publisher_id = publisher_id
    @promo_campaign_id = promo_campaign_id
    @description = description
    @promo_id = promo_id
  end

  def perform
    return if @number <= 0
    return perform_offline if perform_promo_offline?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/2/promo/referral_code/unattached?number=#{@number}")
    end

    payload = JSON.parse(response.body)
    payload.each do |promo_registration|
      PromoRegistration.create!(
        referral_code: promo_registration["referral_code"],
        publisher_id: @publisher_id,
        promo_id: active_promo_id,
        promo_campaign_id: @promo_campaign_id,
        description: @description,
        kind: PromoRegistration::UNATTACHED
      )
    end
  end

  def perform_offline
    promo_registrations = []
    @number.times do
      promo_registrations.push(PromoRegistration.create!(referral_code: offline_referral_code,
                                                         publisher_id: @publisher_id,
                                                         promo_id: active_promo_id,
                                                         promo_campaign_id: @promo_campaign_id,
                                                         description: @description,
                                                         kind: PromoRegistration::UNATTACHED))
    end
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end
end
