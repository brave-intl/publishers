module Uphold
  class Client < BaseApiClient
    attr_accessor :api_base_uri

    def initialize(params = {})
      @connection = connection
      self.api_base_uri = params[:uri]
    end

    def address
      @address ||= Uphold::Models::Address.new(api_base_uri: api_base_uri)
    end

    def card
      @card ||= Uphold::Models::Card.new(api_base_uri: api_base_uri)
    end

    def user
      @user ||= Uphold::Models::User.new(api_base_uri: api_base_uri)
    end

    def transaction
      @transaction ||= Uphold::Models::Transaction.new(api_base_uri: api_base_uri)
    end

    private

    def perform_offline?
      Rails.application.secrets[:uphold_api_uri].blank?
    end
  end
end
