# !! important, We are using UNATTACHED type for now until we move to polymorphic codes. 
class Promo::PeerToPeerRegistration < BaseApiClient
  include PromosHelper

  def initialize(publisher:, promo_campaign_id:, promo_id: active_promo_id)
    @publisher = publisher
    @promo_campaign_id = promo_campaign_id
    @promo_id = promo_id
  end

  def perform
    return perform_offline if perform_promo_offline?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/2/promo/referral_code/owner/#{@publisher.owner_identifier}")
      request.params['peer_to_peer'] = true
    end

    payload = JSON.parse(response.body)
    payload.each do |promo_registration|
      PromoRegistration.create!(
        referral_code: promo_registration["referral_code"],
        publisher_id: @publisher.id,
        promo_id: active_promo_id,
        promo_campaign_id: @promo_campaign_id,
        kind: PromoRegistration::PEER_TO_PEER
      )
    end
  end

  def perform_offline
    promo_registrations = []
    promo_registrations.push(PromoRegistration.create!(referral_code: offline_referral_code,
                                                       publisher_id: @publisher.id,
                                                       promo_id: active_promo_id,
                                                       promo_campaign_id: @promo_campaign_id,
                                                       kind: PromoRegistration::PEER_TO_PEER))
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end
end
