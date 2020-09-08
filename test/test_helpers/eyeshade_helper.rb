module EyeshadeHelper
  def stub_eyeshade_transactions_response(publisher:, transactions: [])
    stub_request(:get, /v1\/accounts.*transactions.*/).
      to_return(status: 200, body: transactions.to_json, headers: {})
  end

  def stub_eyeshade_balances_response(publisher:, balances: [])
    if publisher.channels.verified.count.zero?
      channels_query_string = ""
    else
      channels_query_string = publisher.channels.verified.map { |channel| "&account=#{URI.encode_www_form_component(channel.details.channel_identifier)}"}.reduce(:+)
    end

    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances?account=#{URI.encode_www_form_component(publisher.owner_identifier)}#{channels_query_string}&pending=true").
      to_return(status: 200, body: balances.to_json)
  end

  def stub_all_eyeshade_wallet_responses(publisher:, wallet: {}, balances: [], transactions: [])
    stub_eyeshade_transactions_response(publisher: publisher, transactions: transactions)
    stub_eyeshade_balances_response(publisher: publisher, balances: balances)
  end
end
