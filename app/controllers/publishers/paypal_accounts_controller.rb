module Publishers
  class PaypalAccountsController < ApplicationController
    before_action :authenticate_publisher!

    def start_connect
      p "starting"
      PayPal::SDK.configure({
        :openid_client_id     => Rails.application.secrets[:client_id],
        :openid_client_secret => "client_secret",
        :openid_redirect_uri  => "http://google.com"
      })
      include PayPal::SDK::OpenIDConnect

      # Generate authorize URL to Get Authorize code
      puts Tokeninfo.authorize_url( :scope => "openid profile" )

      # Create tokeninfo by using Authorize Code from redirect_uri
      tokeninfo = Tokeninfo.create("Replace with Authorize Code received on redirect_uri")

      # Refresh tokeninfo object
      tokeninfo.refresh

      # Create tokeninfo by using refresh token
      tokeninfo = Tokeninfo.refresh("Replace with refresh_token")

      # Get Userinfo
      userinfo = tokeninfo.userinfo

      # Get Userinfo by using access token
      userinfo = Userinfo.get("Replace with access_token")
    end

    def connect_callback
    end
  end
end
