# Gets the referral code associated with a channel_id
class Promo::RegistrationGetter < BaseApiClient
  include PromosHelper

  def initialize(publisher:, channel:, promo_id: active_promo_id)
    @publisher = publisher
    @channel = channel
    @promo_id = promo_id

    if !publisher_owners_channel
      raise PublisherChannelMismatchError.new("Cannot retrieve referral code becausse publisher #{publisher.id} does not own channel #{channel.id}.")
    end
  end

  def perform
    return perform_offline if perform_promo_offline?
    # Returns an array of publisher referral_codes, 1 for each promo
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/2/promo/referral_code/channel/#{@channel.channel_id}")
    end
    JSON.parse(response.body)
  end

  def perform_offline
    Rails.logger.info("Promo::RegistrationGetter offline.")
    {}.to_json
  end

  class PublisherChannelMismatchError < RuntimeError; end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end

  def publisher_owners_channel
    @publisher.channels.include?(@channel)
  end
end