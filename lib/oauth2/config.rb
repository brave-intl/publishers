# typed: true

#
# Implemements a strictly typed interface for Oauth2::AuthenticationCodeClient to:
#
# 1. Enforce a standard configuration abstraction for any authentication code oauth2 provider
# 2. Creates Seperate configuration container that can be independently inspected for debugging purposes.
# 3. Pulls non-secret values out of ENV and puts them in a testable format
# 4. Documents/implements the core requirements for all authentication code flows.

module Oauth2::Config
  class AuthorizationCode
    class << self
      attr_accessor :base_authorization_url
      attr_accessor :base_token_url

      def scope
      end

      def client_id
      end

      def client_secret
      end

      def authorization_url
      end

      def token_url
      end

      def redirect_uri
      end

      def content_type
      end

      # This gives us a bit of flexibility to deal with atypical/not-to-spec access token  responses
      # where we must save a specific value that is returned in the response.
      #
      # I don't love it, but it is still explicitly typed.
      def access_token_struct
      end

      def base_redirect_url
        uri = case env
        when "production"
          "https://publishers.basicattentiontoken.org" # FIXME: THis is what bitflyer uses and we can't see it.  Make sure to review the prod env values.
        when "staging"
          "https://publishers-staging.basicattentiontoken.org"
        else
          Rails.configuration.pub_secrets[:creators_full_host]
        end

        URI(uri)
      end

      def is_production?
        env == "production"
      end

      def env
        Rails.env
      end
    end
  end

  class Gemini < AuthorizationCode
    class << self
      def scope
        "balances:read,account:read,payments:create"
      end

      def client_id
        Rails.configuration.pub_secrets[:gemini_client_id]
      end

      def client_secret
        Rails.configuration.pub_secrets[:gemini_client_secret]
      end

      # Gemini auth grant flow uses a different host than api requests
      # See: https://docs.gemini.com/oauth/#authorization-code-grant-flow
      def authorization_url
        url = is_production? ? "https://exchange.gemini.com"
       : "https://exchange.sandbox.gemini.com"

        URI("#{url}/auth")
      end

      # See: https://docs.gemini.com/oauth/#authorization-code-grant-flow
      def token_url
        url = is_production? ? "https://exchange.gemini.com"
       : "https://exchange.sandbox.gemini.com"

        URI("#{url}/auth/token")
      end

      def redirect_uri
        URI("#{base_redirect_url}/publishers/gemini_connection/new")
      end

      def content_type
        "application/json" # See Oauth2::AuthorizationCode.new
      end

      def access_token_struct
        Oauth2::Responses::AccessTokenResponse
      end
    end
  end

  class Uphold < AuthorizationCode
    class << self
      def base_token_url
        is_production? ? "https://api.uphold.com"
           : "https://api-sandbox.uphold.com"
      end

      def scope
        "cards:read user:read cards:write transactions:read"
      end

      def client_id
        Rails.configuration.pub_secrets[:uphold_client_id]
      end

      def client_secret
        Rails.configuration.pub_secrets[:uphold_client_secret]
      end

      def authorization_url
        base_authorization_url = is_production? ? "https://uphold.com"
     : "https://sandbox.uphold.com"

        URI("#{base_authorization_url}/authorize/#{client_id}")
      end

      def token_url
        URI("#{base_token_url}/oauth2/token")
      end

      def content_type
        "application/x-www-form-urlencoded"
      end

      def redirect_uri
        URI("#{base_redirect_url}/publishers/uphold_verified")
      end

      def access_token_struct
        Oauth2::Responses::AccessTokenResponse
      end
    end
  end

  class Bitflyer < AuthorizationCode
    class << self
      def scope
        "create_deposit_id"
      end

      def client_id
        Rails.configuration.pub_secrets[:bitflyer_client_id]
      end

      def client_secret
        Rails.configuration.pub_secrets[:bitflyer_client_secret]
      end

      def authorization_url
        base_authorization_url = is_production? ? "https://bitflyer.com" : "https://demo24kiuw4dcyncsy3qlud8u8.azurewebsites.net"
        URI("#{base_authorization_url}/ex/OAuth/authorize")
      end

      def token_url
        base_token_url = is_production? ? "https://bitflyer.com" : "https://demo24kiuw4dcyncsy3qlud8u8.azurewebsites.net"
        URI("#{base_token_url}/api/link/v1/token")
      end

      def content_type
        "application/json"
      end

      def redirect_uri
        URI("#{base_redirect_url}/publishers/bitflyer_connection/new")
      end

      def access_token_struct
        Oauth2::Responses::BitflyerAccessTokenResponse
      end
    end
  end
end
