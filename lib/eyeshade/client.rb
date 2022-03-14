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

    # Note:
    #
    # I encountered an error when attempting to use T.type_alias { T.any(Type1, Typ2) }  annotations on these private methods
    # The sorbet type checker considered the allowed responses to be invalid when the annotations for each public method were run.
    # Having the annotations on the public endpoints is more important IMO and I don't want to get bogged down in what may be an actual limitation/feature of sorbet.
    # I may raise an issue look around on the sorbet github repo.
    def request_and_return(method, path, response_struct, payload: nil)
      resp = connection.send(method) do |request|
        request.headers["Authorization"] = api_authorization_header
        request.url client_url(path)

        if payload
          request.body = JSON.dump(payload)
        end
      end

      parse_array_response_to_struct(resp, response_struct)
    end

    def parse_array_response_to_struct(response, struct)
      if response.success?
        data = JSON.parse(response.body, symbolize_names: true)
        data.map { |obj| struct.new(**obj) }
      else
        []
      end
    end

    def client_url(path)
      [api_base_uri, path].join("")
    end

    def api_base_uri
      Rails.application.secrets[:api_eyeshade_base_uri]
    end

    def api_authorization_header
      "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
    end
  end
end
