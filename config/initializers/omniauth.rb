require "omniauth-oauth2"

OmniAuth.config.logger = Rails.logger

if !Rails.env.test?
  OmniAuth.config.full_host = lambda do |env|
    Rails.configuration.pub_secrets[:creators_full_host]
  end
end

module OmniAuth
  module Strategies
    class OAuth2
      def request_phase
        options[:authorize_params] = authorize_params
        options[:authorize_params].merge!(request.params)

        # Generate the authorization URL
        url = client.auth_code.authorize_url({redirect_uri: callback_url}.merge(options[:authorize_params]))

        # Return the authorization URL as JSON
        Rack::Response.new([{auth_url: url}.to_json], 200, "Content-Type" => "application/json").finish
      end
    end
  end
end

# the twitch library implements request_phase separately
module OmniAuth
  module Strategies
    class Twitch < OmniAuth::Strategies::OAuth2
      def request_phase
        options[:authorize_params] = authorize_params
        options[:authorize_params].merge!(request.params)

        # Generate the authorization URL
        url = client.auth_code.authorize_url({redirect_uri: callback_url}.merge(options[:authorize_params]))

        # Return the authorization URL as JSON
        Rack::Response.new([{auth_url: url}.to_json], 200, "Content-Type" => "application/json").finish
      end
    end
  end
end
