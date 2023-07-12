# typed: true

# Updates the promo server when a channel has been deleted or moved owners
class Promo::ChannelOwnerUpdater < BaseApiClient
  include PromosHelper

  def initialize(referral_code:, publisher_id: "removed")
    @publisher_id = publisher_id
    @referral_code = referral_code # The brave_publisher_id or youtube channel id, not uuid
  end

  def perform
    return perform_offline if perform_promo_offline?
    return nil if @referral_code.nil?
    connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/1/promo/publishers/#{@referral_code}")
      request.body = {owner_id: @publisher_id}.to_json
    end
  end

  def perform_offline
    true
  end

  private

  def proxy_url
    nil
  end

  def api_base_uri
    Rails.application.credentials[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.credentials[:api_promo_key]}"
  end
end
