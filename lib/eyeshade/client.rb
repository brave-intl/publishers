# typed: true

# TODO: Consolidate all of the eyeshade API requests here and define explicit types for each
# See: app/services/eyeshade/*

module Eyeshade
  class Client < BaseApiClient
    include Eyeshade::Types

    def accounts_balances(payload)
      request_and_return(:post, "/v1/accounts/balances", AccountBalance, payload: payload)
    end

    def accounts_earnings_referrals_total
      request_and_return(:get, "/v1/accounts/earnings/referrals/total", ReferralEarningTotal)
    end

    def account_transactions(id)
      request_and_return(:get, "/v1/accounts/#{id}/transactions", Transaction)
    end

    private

    def api_base_uri
      Rails.configuration.pub_secrets[:api_eyeshade_base_uri]
    end

    def api_authorization_header
      "Bearer #{Rails.configuration.pub_secrets[:api_eyeshade_key]}"
    end
  end
end
