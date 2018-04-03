# Updates the promo server when a channel has been deleted or moves owners
class PromoChannelOwnerUpdater < BaseApiClient
  include PromosHelper

  def initialize(publisher_id: "removed", referral_code:)
    @publisher_id = publisher_id
    @referral_code = referral_code # The brave_publisher_id or youtube channel id, not uuid
  end

  def perform
    return perform_offline if perform_promo_offline?
    return nil if @referral_code.nil?
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/1/promo/publishers/#{@referral_code}")
      request.body = { "owner_id": @publisher_id }.to_json
    end
  rescue => e
    require "sentry-raven"
    Rails.logger.error("PromoChannelOwnerUpdater #perform error: #{e}, publisher: #{@publisher.id}")
    Raven.capture_exception("PromoChannelOwnerUpdater #perform error: #{e}, publisher: #{@publisher.id}")
    nil
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