require "faraday"

module Publishers
  class PaypalAccountsController < ApplicationController
    before_action :authenticate_publisher!

    def disconnect
      current_publisher.paypal_connections.active.update_all(hidden: true)
    end

    def refresh
      # (Albert Wang): I don't think Paypal will go down that often, but we can change this into perform_later
      # if this is a long running call.
      Paypal::RefreshIdentity.new(publisher_id: current_publisher.id).perform
      flash[:alert] = I18n.t('publishers.paypal_account_panel.still_not_verified') unless current_publisher.paypal_connection.verified_account?
      redirect_to home_publishers_path
    end

    def connect_callback
      authorization_code = params[:code]
      result = Faraday.post("#{Rails.application.secrets[:paypal_api_uri]}/v1/oauth2/token") do |req|
        req.headers['Authorization'] = "Basic " + Base64.encode64("#{Rails.application.secrets[:paypal_client_id]}:#{Rails.application.secrets[:paypal_client_secret]}").rstrip.tr("\n", "")
        req.headers['Accept'] = 'application/json'
        req.headers['Accept-Language'] = "en_US"
        req.params['grant_type'] = "authorization_code"
        req.params['code'] = authorization_code
      end

      access_token = JSON.parse(result.body)["access_token"]
      refresh_token = JSON.parse(result.body)["refresh_token"]

      user_info_response = Faraday.get("#{Rails.application.secrets[:paypal_api_uri]}/v1/identity/oauth2/userinfo") do |req|
        req.headers['Authorization'] = "Bearer #{access_token}"
        req.headers['Accept'] = 'application/json'
        req.params['schema'] = "paypalv1.1"
      end

      user_info = JSON.parse(user_info_response.body)
      paypal_connection = PaypalConnection.find_or_initialize_by(
        user_id: current_publisher.id,
        email: user_info['emails'][0]['value']
      )
      paypal_connection.update(
        refresh_token: refresh_token,
        email: user_info['emails'][0]['value'],
        country: user_info['address']['country'],
        verified_account: user_info['verified_account'] == 'true',
        paypal_account_id: user_info['user_id'],
        hidden: false
      )

      redirect_to home_publishers_path
    end
  end
end
