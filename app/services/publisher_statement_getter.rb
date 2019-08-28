class PublisherStatementGetter < BaseApiClient
  attr_reader :publisher

  class Statement
    include ActiveModel::Model
    attr_accessor :channel, :created_at, :description, :transaction_type, :amount, :settlement_currency, :settlement_amount, :settlement_destination_type, :settlement_destination
  end

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    transactions = PublisherTransactionsGetter.new(publisher: publisher).perform
    transactions = replace_account_identifiers_with_titles(transactions)

    transactions += get_uphold_transactions
    transactions.sort_by { |x| x.created_at }
    transactions
  end

  private

  def replace_account_identifiers_with_titles(transactions)
    channels = {}

    transactions.map do |transaction|
      account_identifier = transaction["channel"]
      if account_identifier.starts_with?(Publisher::OWNER_PREFIX)
        transaction["channel"] = I18n.t("publishers.statements.index.account")
      elsif account_identifier.blank?
        transaction["channel"] = "Manual"
      else
        channel ||= channels[account_identifier]
        if channel.blank?
          channels[account_identifier] = Channel.find_by_channel_identifier(account_identifier)&.publication_title
          channel = channels[account_identifier] || account_identifier
        end
        transaction["channel"] = channel
      end

      Statement.new(
        channel: transaction["channel"],
        description: transaction["description"],
        transaction_type: transaction["transaction_type"],
        amount: transaction["amount"]&.to_d,
        settlement_currency: transaction["settlement_currency"],
        settlement_amount: transaction["settlement_amount"]&.to_d,
        settlement_destination_type: transaction["settlement_destination_type"],
        settlement_destination: transaction["settlement_destination"],
        created_at: transaction["created_at"].to_date
      )
    end
  end

  def get_uphold_transactions
    uphold = []

    publisher.uphold_connection.uphold_connection_for_channels.each do |card_connection|
      transactions = card_connection.uphold_connection.uphold_client.transaction.all(id: card_connection.card_id)
      next if transactions.blank?

      transactions.each do |transaction|
        puts JSON.pretty_generate(transaction.as_json)
        uphold << Statement.new(
          channel: card_connection.channel.details.publication_title,
          transaction_type: "uphold_contribution",
          amount: -transaction.origin.dig('amount')&.to_d,
          settlement_currency: transaction.destination.dig('currency'),
          settlement_amount: transaction.destination.dig('amount')&.to_d,
          created_at: transaction.createdAt.to_date,
        )
      end
    end

    uphold
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
