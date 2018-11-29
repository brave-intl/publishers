# Tells the promo server to pause or unpause tracking for a list of referral codes
class Promo::UnattachedRegistrationStatusUpdater < BaseApiClient
  include PromosHelper
  STATUSES = ["active", "paused"].freeze

  def initialize(promo_registrations:, status:)
    raise if STATUSES.exclude?(status)
    @status = status
    @promo_registrations = promo_registrations
    @referral_codes = promo_registrations.map { |promo_registration|
      promo_registration.referral_code
    }
  end

  def perform
    return if @referral_codes.count <= 0
    return true if perform_promo_offline?
    response = connection.patch do |request|
      request.options.params_encoder = Faraday::FlatParamsEncoder
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/api/2/promo/referral#{query_string}")
      request.body = {status: @status}.to_json
    end

    if response.status == 200
      @status == "active" ? @promo_registrations.update_all(active: true) : @promo_registrations.update_all(active: false)
    end

    response
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_promo_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_promo_key]}"
  end

  def query_string
    query_string = "?"
    @referral_codes.each do |referral_code|
      query_string = "#{query_string}referral_code=#{referral_code}&"
    end
    query_string.chomp("&") # Remove the final ampersand
  end
end