module Uphold
  class Client < BaseApiClient
    def initialize(params = {})
      @connection = connection
    end

    def card
      @card ||= Uphold::Models::Card.new
    end

    def user
      @user ||= Uphold::Models::User.new
    end

    private

    def perform_offline?
      Rails.application.secrets[:uphold_api_uri].blank?
    end

    def api_base_uri
      Rails.application.secrets[:uphold_api_uri]
    end
  end
end
