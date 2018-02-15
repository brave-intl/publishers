# Fetches/sets the referral stats for a Owner
class PublisherPromoStatsFetcher < BaseApiClient
  include PromosHelper

  def initialize(publisher:, promo_id: active_promo_id)
    @publisher = publisher
    @promo_id = promo_id
  end

  def perform
    return unless @publisher.promo_stats_status == :update
    return perform_offline if perform_promo_offline?
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/1/promo/owners/#{@publisher.id}/statsByTime?promo_id=#{@promo_id}")
    end
    stats = JSON.parse(response.body)
    @publisher.promo_stats_2018q1 = stats
    @publisher.save!
  rescue => e
    require "sentry-raven"
    Rails.logger.error("PublisherPromoStatsFetcher #perform error: #{e}, publisher: #{@publisher}")
    Raven.capture_exception("PublisherPromoStatsFetcher #perform error: #{e}, publisher: #{@publisher}")
    nil
  end

  def perform_offline
    stats = offline_promo_stats
    @publisher.promo_stats_2018q1 = stats
    @publisher.save!
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end
end