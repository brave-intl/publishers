# typed: ignore
# frozen_string_literal: true

module Bitflyer
  class Http < BaseApiClient
    def self.client_secret
      Rails.application.secrets[:bitflyer_client_secret]
    end

    def self.client_id
      Rails.application.secrets[:bitflyer_client_id]
    end

    def self.oauth_path
      "/api/link/v1/token"
    end

    def self.oauth_scope
      Rails.application.secrets[:bitflyer_scope]
    end

    # Needed for post/get etc
    def api_base_uri
      Rails.application.secrets[:bitflyer_host]
    end
  end
end
