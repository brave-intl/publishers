# Retrieves a list of transactions for an owner account
class PublisherTransactionsGetter < BaseApiClient
  attr_reader :publisher

  OFFLINE_NUMBER_OF_SETTLEMENTS = 2
  OFFLINE_REFERRAL_SETTLEMENT_AMOUNT = "18.81"
  OFFLINE_CONTRIBUTION_SETTLEMENT_AMOUNT = "56.81"

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("v1/accounts/#{URI.escape(publisher.owner_identifier)}/transactions")
    end

    JSON.parse(response.body)
    # Example eyeshade response
    # [
    #   {
    #     "created_at": "2018-04-08T00:23:09.000Z",
    #     "description": "contributions in March",
    #     "channel": "diracdeltas.github.io",
    #     "amount": "294.617182149806375904",
    #     "transaction_type": "contribution"
    #   },
    #   {
    #     "created_at": "2018-04-08T00:23:10.000Z",
    #     "description": "settlement fees for contributions",
    #     "channel": "diracdeltas.github.io",
    #     "amount": "-14.730859107490318795",
    #     "transaction_type": "fee"
    #   },
    #   {
    #     "created_at": "2018-04-08T00:33:09.000Z",
    #     "description": "payout for referrals",
    #     "channel": "diracdeltas.github.io",
    #     "amount": "-94.617182149806375904",
    #     "settlement_currency": "USD",
    #     "settlement_amount": "18.81",
    #     "transaction_type": "referral_settlement"
    #   }
    # ]
  rescue Faraday::ClientError => e
    Rails.logger.info "Error receiving eyeshade transactions #{e.message}"
    []
  end

  def perform_offline
    transactions = []
    i = 0
    OFFLINE_NUMBER_OF_SETTLEMENTS.times do
      publisher.channels.verified.each do |channel|
        base_date = i.month.ago.at_beginning_of_month + 6.days
        contribution_amount = "294.617182149806375904"
        contribution_fees_amount = "-14.730859107490318795"
        contribution_settlement_amount = "-279.886323042316057109"

        referral_amount = "94.617182149806375904"
        referral_settlement_amount = "-94.617182149806375904"

        # Contributions in
        transactions.push({
          "created_at" => "#{base_date}",
          "description" => "contributions in month x",
          "channel" => "#{channel.details.channel_identifier}",
          "amount" => "#{contribution_amount}",
          "transaction_type" => "contribution",
          "settlement_currency" => "ETH",
          "type" => "contribution"
        })

        # Contribution fees out
        transactions.push({
          "created_at" => "#{base_date}",
          "description" => "settlement fees for contributions",
          "channel" => "#{channel.details.channel_identifier}",
          "amount" => "#{contribution_fees_amount}",
          "transaction_type" => "fee",
          "settlement_currency" => "ETH",
        })

        # Contribution settlement out
        transactions.push({
          "created_at" => "#{base_date}",
          "description" => "payout for contributions",
          "channel" => "#{channel.details.channel_identifier}",
          "amount" => "#{contribution_settlement_amount}",
          "transaction_type" => "contribution_settlement",
          "settlement_currency" => "ETH",
          "settlement_amount" => OFFLINE_CONTRIBUTION_SETTLEMENT_AMOUNT,
        })

        # Referrals in
        transactions.push({
          "created_at" => "#{base_date}",
          "description" => "referrals in month x",
          "channel" => "#{channel.details.channel_identifier}",
          "amount" => "#{referral_amount}",
          "transaction_type" => "referral",
          "settlement_currency" => "ETH",
        })

        # Referal settlement out
        transactions.push({
          "created_at" => "#{base_date}",
          "description" => "payout for referrals",
          "channel" => "#{channel.publisher.owner_identifier}",
          "amount" => "#{referral_settlement_amount}",
          "transaction_type" => "referral_settlement",
          "settlement_currency" => "ETH",
          "settlement_amount" => OFFLINE_REFERRAL_SETTLEMENT_AMOUNT,
        })
      end
      i += 1
    end
    transactions.sort_by { |transaction|
      transaction["created_at"].to_date
    }
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
