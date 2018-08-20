# Updates the promo server when a channel has been deleted or moves owners
class PromoChannelOwnerUpdater < BaseApiClient
  include PromosHelper

  def initialize(publisher: "removed", referral_code:)
    @publisher_id = publisher == "removed" ? "removed" : publisher.id
    @referral_code = referral_code
  end

  def perform
    return perform_offline if perform_promo_offline?
    return if @referral_code.nil?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/1/promo/publishers/#{@referral_code}")
      request.body = { "owner_id": @publisher_id }.to_json
    end
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