module Uphold
  class Client < BaseApiClient
    attr_accessor :api_base_uri, :value

    def initialize(params = {})
      @connection = connection
      @value = 0
      self.api_base_uri = params[:uri]
    end

    def set_value(val)
      @value = val
    end

    def get_value
      @value
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
      @transaction ||= Uphold::Models::Transaction.new
    end

    private

    def perform_offline?
      Rails.application.secrets[:uphold_api_uri].blank?
    end
  end
end
