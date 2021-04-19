module Bitflyer
  @response_type = "code"

  class << self
    attr_reader :response_type

    def client_secret
      Rails.application.secrets[:bitflyer_client_secret]
    end

    def client_id
      Rails.application.secrets[:bitflyer_client_id]
    end

    def api_base_uri
      Rails.application.secrets[:bitflyer_host]
    end

    def oauth_path
      '/api/link/v1/token'
    end

    def scope
      Rails.application.secrets[:bitflyer_scope]
    end
  end
end
