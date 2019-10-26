class Paypal::RefreshIdentity < BaseService

  def initialize(publisher_id:)
    @publisher = Publisher.find(publisher_id)
    @paypal_connection = @publisher.paypal_connection
  end

  def perform
    return if @paypal_connection.nil? || @paypal_connection.refresh_token.nil?
    user_info_response = Faraday.get("https://api.sandbox.paypal.com/v1/identity/oauth2/userinfo") do |req|
      req.headers['Authorization'] = "Bearer #{@paypal_connection.access_token}"
      req.headers['Accept'] = 'application/json'
      req.params['schema'] = "paypalv1.1"
    end

    user_info = JSON.parse(user_info_response.body)
    paypal_connection = PaypalConnection.find_by(
      user_id: @publisher.id
    )
    paypal_connection.update(
      email: user_info['emails'][0]['value'],
      country: user_info['address']['country'],
      verification_status: user_info['verified_account'],
      paypal_account_id: user_info['user_id']
    )
  end
end
