# Updates the promo server when a channel has been deleted or moved owners
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

  # def request_body
  #   case @channel.details_type
  #   when "YoutubeChannelDetails"
  #     return youtube_request_body
  #   when "SiteChannelDetails"
  #     return site_request_body
  #   else
  #     raise
  #   end
  # end

  # def youtube_request_body
  #   {
  #     "owner_id": @publisher_id,
  #     "title": @channel.publication_title,
  #     "channel_type": "youtube",
  #     "thumbnail_url": @channel.details.thumbnail_url,
  #     "description": @channel.details.description.presence
  #   }.to_json
  # end

  # def site_request_body
  #   {
  #     "owner_id": @publisher_id,
  #     "title": @channel.publication_title,
  #     "channel_type": "website"
  #   }.to_json
  # end
end