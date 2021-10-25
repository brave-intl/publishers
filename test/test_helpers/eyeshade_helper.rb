module EyeshadeHelper
  def stub_eyeshade_transactions_response(publisher:, transactions: [])
    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/#{URI.encode_www_form_component(publisher.owner_identifier)}/transactions")
      .to_return(status: 200, body: transactions.to_json, headers: {})
  end

  def stub_eyeshade_balances_response(publisher:, balances: [])
    accounts = [publisher.owner_identifier] + publisher.channels.verified.map { |channel| channel.details.channel_identifier }
    stub_request(:post, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances")
      .with(body: {account: accounts, pending: true})
      .to_return(status: 200, body: balances.to_json)
  end

  def stub_all_eyeshade_wallet_responses(publisher:, wallet: {}, balances: [], transactions: [])
    stub_eyeshade_transactions_response(publisher: publisher, transactions: transactions)
    stub_eyeshade_balances_response(publisher: publisher, balances: balances)
  end
end
