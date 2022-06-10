# typed: true

# TODO: Consolidate all of the eyeshade API requests here and define explicit types for each
# See: app/services/eyeshade/*
#
# TODO: Remove the duplication of each request type.  I'm holding my hose on this as it is of secondary importance to the core archiecture.

module Eyeshade
  class Client < BaseApiClient
    include Eyeshade::Types
    extend T::Sig

    sig { params(payload: T::Hash[String, T.untyped]).returns(AccountBalances) }
    def accounts_balances(payload)
      request_and_return(:post, "/v1/accounts/balances", AccountBalance, payload: payload)
    end

    # TODO: Add spec
    sig { returns(ReferralEarningTotals) }
    def accounts_earnings_referrals_total
      request_and_return(:get, "/v1/accounts/earnings/referrals/total", ReferralEarningTotal)
    end

    sig { params(id: String).returns(Transactions) }
    def account_transactions(id)
      request_and_return(:get, "/v1/accounts/#{id}/transactions", Transaction)
    end

    private

    def api_base_uri
      Rails.application.secrets[:api_eyeshade_base_uri]
    end

    def api_authorization_header
      "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
    end
  end
end
