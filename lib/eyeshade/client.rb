# typed: true

# TODO: Consolidate all of the eyeshade API requests here and define explicit types for each
# See: app/services/eyeshade/*

module Eyeshade
  class Client < BaseApiClient
    include Eyeshade::Types
    extend T::Sig
    class ResultError < StandardError; end

    sig { params(payload: T::Hash[String, T.untyped]).returns(T.any(AccountBalances, Faraday::Response)) }
    def accounts_balances(payload)
      result = request_and_return(:post, "/v1/accounts/balances", AccountBalance, payload: payload)

      case result
      when Array
        T.cast(result, AccountBalances)
      when Faraday::Response
        result
      when T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end

    sig { returns(T.any(ReferralEarningTotals, Faraday::Response)) }
    def accounts_earnings_referrals_total
      result = request_and_return(:get, "/v1/accounts/earnings/referrals/total", ReferralEarningTotal)

      case result
      when Array
        T.cast(result, ReferralEarningTotals)
      when Faraday::Response
        result
      when T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
    end

    sig { params(id: String).returns(T.any(Transactions, Faraday::Response)) }
    def account_transactions(id)
      result = request_and_return(:get, "/v1/accounts/#{id}/transactions", Transaction)

      case result
      when Array
        T.cast(result, Transactions)
      when Faraday::Response
        result
      when T::Struct
        raise ResultError
      else
        T.absurd(result)
      end
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
