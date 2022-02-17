# typed: true

module Eyeshade
  class Client < BaseApiClient
    include Eyeshade::Types
    extend T::Sig

    StructTypes = T.type_alias { T.any(AccountBalance, Transaction) }
    ResponseTypes = T.type_alias { T.any(AccountBalances, Transactions) }

    sig { params(payload: T::Hash[String, T.untyped]).returns(AccountBalances) }
    def accounts_balances(payload)
      # FIXME use request if you can
      resp = connection.send(:post) do |req|
        req.options.open_timeout = 5
        req.options.timeout = 20
        req.url client_url("/v1/accounts/balances")
        req.headers["Authorization"] = api_authorization_header
        req.headers["Content-Type"] = "application/json"
        req.body = JSON.dump(payload)
      end

      parse_array_response_to_struct(resp, AccountBalance)
    end

    sig { params(id: String).returns(Transactions) }
    def account_transactions(id)
      # FIXME: use request
      resp = connection.get do |request|
        request.headers["Authorization"] = api_authorization_header
        request.url client_url("/v1/accounts/#{id}/transactions")
      end

      parse_array_response_to_struct(resp, Transaction)
    end

    private

    # This throws an error that... I don't thinkis correct.
    #    sig { params(response: ActiveRecord::Response, struct: StructTypes).returns(ResponseTypes) }
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
