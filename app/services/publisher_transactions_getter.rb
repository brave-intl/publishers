# typed: true

# Retrieves a list of transactions for an owner account
class PublisherTransactionsGetter < BaseApiClient
  attr_reader :publisher

  OFFLINE_NUMBER_OF_SETTLEMENTS = 2
  OFFLINE_REFERRAL_SETTLEMENT_AMOUNT = "18.81"
  OFFLINE_CONTRIBUTION_SETTLEMENT_AMOUNT = "56.81"
  OFFLINE_CANONICAL_PUBLISHER_ID = "publishers#uuid:709033b2-0567-4ab2-9467-95ba3343e568"
  OFFLINE_UPHOLD_ACCOUNT_ID = "bdfd128a-976e-4a42-b07a-3fab7fb2cbea"
  OFFLINE_PAYMENT_ACCOUNT_ID = "f6221085-e2e4-45e3-9ba8-17c6572b42fe"

  REFERRAL_DEPRECATION_ACCOUNT = "referral-deprecation-account"

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.configuration.pub_secrets[:api_eyeshade_offline]

    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("v1/accounts/#{URI.encode_www_form_component(publisher.owner_identifier)}/transactions")
    end

    transactions = JSON.parse(response.body)

    # In the statements and balances, we don't want to show transactions that balance out the accounting on eyeshade
    transactions.reject! { |transaction| transaction["to_account"] == PublisherTransactionsGetter::REFERRAL_DEPRECATION_ACCOUNT }
    transactions
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
          "from_account" => "helloworld.com",
          "to_account" => OFFLINE_CANONICAL_PUBLISHER_ID,
          "created_at" => base_date.to_s,
          "description" => "contributions in month x",
          "channel" => channel.details.channel_identifier.to_s,
          "amount" => contribution_amount.to_s,
          "transaction_type" => "contribution",
          "settlement_currency" => "ETH",
          "type" => "contribution"
        })

        # Contribution fees out
        transactions.push({
          "from_account" => OFFLINE_CANONICAL_PUBLISHER_ID,
          "to_account" => "fees-account",
          "created_at" => base_date.to_s,
          "description" => "settlement fees for contributions",
          "channel" => channel.details.channel_identifier.to_s,
          "amount" => contribution_fees_amount.to_s,
          "transaction_type" => "fees",
          "settlement_currency" => "ETH"
        })

        # Contribution settlement out
        # This goes out to the publisher's uphold account
        transactions.push({
          "from_account" => OFFLINE_CANONICAL_PUBLISHER_ID,
          "to_account" => OFFLINE_UPHOLD_ACCOUNT_ID,
          "created_at" => base_date.to_s,
          "description" => "payout for contributions",
          "channel" => channel.details.channel_identifier.to_s,
          "amount" => contribution_settlement_amount.to_s,
          "transaction_type" => "contribution_settlement",
          "settlement_currency" => "ETH",
          "settlement_amount" => OFFLINE_CONTRIBUTION_SETTLEMENT_AMOUNT
        })

        # Referrals in
        transactions.push({
          "from_account" => OFFLINE_PAYMENT_ACCOUNT_ID,
          "to_account" => OFFLINE_CANONICAL_PUBLISHER_ID,
          "created_at" => base_date.to_s,
          "description" => "referrals in month x",
          "channel" => channel.details.channel_identifier.to_s,
          "amount" => referral_amount.to_s,
          "transaction_type" => "referral",
          "settlement_currency" => "ETH"
        })

        # Referral deprecation
        transactions.push({
          "from_account" => OFFLINE_CANONICAL_PUBLISHER_ID,
          "to_account" => REFERRAL_DEPRECATION_ACCOUNT,
          "created_at" => base_date.to_s,
          "description" => "Transaction to cancel referrals finalizing past 90 days after 2021-01-23 for legacy referrals.",
          "amount" => (-referral_amount).to_s,
          "transaction_type" => "manual"
        })

        # Referal settlement out
        transactions.push({
          "from_account" => OFFLINE_CANONICAL_PUBLISHER_ID,
          "to_account" => OFFLINE_UPHOLD_ACCOUNT_ID,
          "created_at" => base_date.to_s,
          "description" => "payout for referrals",
          "channel" => channel.publisher.owner_identifier.to_s,
          "amount" => referral_settlement_amount.to_s,
          "transaction_type" => "referral_settlement",
          "settlement_currency" => "ETH",
          "settlement_amount" => OFFLINE_REFERRAL_SETTLEMENT_AMOUNT
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
    Rails.configuration.pub_secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.configuration.pub_secrets[:api_eyeshade_key]}"
  end
end
