# require 'omniauth-twitter2'

# module OmniAuth
#   module Strategies
#     class CustomTwitter < OmniAuth::Strategies::Twitter2
#       def request_phase
#         # Generate the authorization URL
#         options[:authorize_params] = authorize_params
#         options[:authorize_params].merge!(request.params)
#         url = client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(options[:authorize_params]))

#         # Return the authorization URL as JSON
#         if request.xhr?
#           return Rack::Response.new([{ auth_url: url }.to_json], 200, 'Content-Type' => 'application/json').finish
#         else
#           redirect url
#         end
#       end
#     end
#   end
# end
