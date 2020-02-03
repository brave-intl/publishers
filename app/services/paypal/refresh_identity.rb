class Paypal::RefreshIdentity < BaseService
  def initialize(publisher_id:)
    @publisher = Publisher.find(publisher_id)
    @paypal_connection = @publisher.paypal_connection
  end

  def perform
    return if @paypal_connection.nil? || @paypal_connection.refresh_token.nil?
    begin
      access_token = fetch_access_token
      raise_token_exception! if access_token.nil?
    rescue => e
      Raven.capture_exception(e)
    end

    user_info_response = Faraday.get("#{Rails.application.secrets[:paypal_api_uri]}/v1/identity/oauth2/userinfo") do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Accept'] = 'application/json'
      req.params['schema'] = "paypalv1.1"
    end

    user_info = JSON.parse(user_info_response.body)
    paypal_connection = PaypalConnection.find_by(
      user_id: @publisher.id,
      hidden: false
    )
    paypal_connection.update(
      country: user_info.dig('address', 'country'),
      verified_account: user_info.dig('verified_account'),
      paypal_account_id: user_info.dig('user_id'),
      payer_id: user_info.dig('payer_id')
    )
  end

  private

  def raise_token_exception!
    raise "Access token is nil for publisher: #{@publisher.id}"
  end

  def fetch_access_token
    result = Faraday.post("#{Rails.application.secrets[:paypal_api_uri]}/v1/oauth2/token") do |req|
      req.headers['Authorization'] = "Basic " + Base64.encode64("#{Rails.application.secrets[:paypal_client_id]}:#{Rails.application.secrets[:paypal_client_secret]}").rstrip.tr("\n", "")
      req.headers['Accept'] = 'application/json'
      req.headers['Accept-Language'] = "en_US"
      req.params['grant_type'] = "refresh_token"
      req.params['refresh_token'] = @paypal_connection.refresh_token
    end

    JSON.parse(result.body)['access_token']
  end
end
