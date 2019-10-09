module Uphold
  class Client < BaseApiClient
    def initialize(params = {})
      @connection = connection
      @uphold_connection = params[:uphold_connection]
    end

    def address
      @address ||= Uphold::Models::Address.new
    end

    def card
      @card ||= Uphold::Models::Card.new
    end

    def user
      @user ||= Uphold::Models::User.new
    end

    def transaction
      @transaction ||= Uphold::Models::Transaction.new(uphold_connection: @uphold_connection)
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
