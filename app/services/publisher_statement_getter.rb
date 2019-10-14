class PublisherStatementGetter < BaseApiClient
  attr_reader :publisher

  class Statement
    include ActiveModel::Model
    attr_accessor :channel, :created_at, :description, :transaction_type, :amount, :settlement_currency, :settlement_amount, :settlement_destination_type, :settlement_destination

    UPHOLD_CONTRIBUTION = "uphold_contribution".freeze
    UPHOLD_CONTRIBUTION_SETTLEMENT = "uphold_contribution_settlement".freeze
  end

  def initialize(publisher:)
    @publisher = publisher
    @channel_identifiers = {}
  end

  def perform
    transactions = PublisherTransactionsGetter.new(publisher: publisher).perform
    transactions = replace_account_identifiers_with_titles(transactions)

    transactions += get_uphold_transactions
    transactions.sort_by { |x| x.created_at }
  end

  private

  def replace_account_identifiers_with_titles(transactions)
    transactions.map do |transaction|
      account_identifier = transaction["channel"]
      if account_identifier.starts_with?(Publisher::OWNER_PREFIX)
        transaction["channel"] = I18n.t("publishers.statements.index.account")
      elsif account_identifier.blank?
        transaction["channel"] = "Manual"
      else
        transaction["channel"] = channel_name(account_identifier)
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
        created_at: transaction["created_at"].to_date,
      )
    end
  end

  def get_uphold_transactions
    uphold = []

    publisher.uphold_connection.uphold_connection_for_channels.each do |card_connection|
      transactions = card_connection.uphold_connection.uphold_client.transaction.all(id: card_connection.card_id)
      next if transactions.blank?

      transactions.each do |transaction|
        uphold << Statement.new(
          channel: card_connection.channel.details.publication_title,
          transaction_type: Statement::UPHOLD_CONTRIBUTION,
          amount: transaction.origin.dig("amount")&.to_d,
          settlement_currency: transaction.destination.dig("currency"),
          settlement_amount: transaction.destination.dig("amount")&.to_d,
          created_at: transaction.createdAt.to_date,
        )
      end
    end

    # Replicate the similar behavior of Eyeshade. Aggregates all the contribution amounts for the month, and puts them into one entry
    uphold.group_by { |u| u.created_at.at_end_of_month }.each do |date, entries|
      entries.group_by { |e| e.channel }.each do |channel, channel_entries|
        amount = channel_entries.sum { |x| x.amount }

        # We're specifying a negative amount because we group by transactions already paid out.
        # This gives us the ability to aggregate and show one Uphold transaction, rather than 300 or so tips that might have been sent.
        uphold << Statement.new(
          channel: channel,
          transaction_type: Statement::UPHOLD_CONTRIBUTION_SETTLEMENT,
          amount: -amount,
          settlement_currency: "BAT",
          settlement_amount: amount,
          created_at: date,
        )
      end
    end

    uphold
  rescue Faraday::ClientError
    Rails.logger.info("Couldn't access publisher #{@publisher.id} Uphold Transaction History")
    []
  end

  def channel_name(identifier)
    channel ||= @channel_identifiers[identifier]
    if channel.blank?
      @channel_identifiers[identifier] = Channel.find_by_channel_identifier(identifier)&.publication_title
      @channel_identifiers[identifier] ||= identifier
    end

    @channel_identifiers[identifier]
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
