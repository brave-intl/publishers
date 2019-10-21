require "faraday"

module Publishers
  class PaypalAccountsController < ApplicationController
    before_action :authenticate_publisher!

    def start_connect
    end

    def connect_callback
      authorization_code = params[:code]
      current_publisher.update(name: authorization_code)
      p "albert #{authorization_code}"
      result = Faraday.post("https://api.sandbox.paypal.com/v1/oauth2/token") do |req|
        req.headers['Authorization'] = "Basic #{Rails.application.secrets[:paypal_client_id]}:#{Rails.application.secrets[:paypal_client_secret]}="
        req.params['grant_type'] = "authorization_code"
        req.params['code'] = authorization_code
      end
    end
  end
end
