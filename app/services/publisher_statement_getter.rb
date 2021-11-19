# typed: false
class PublisherStatementGetter < BaseApiClient
  attr_reader :publisher

  class Statement
    include ActiveModel::Model
    attr_accessor :channel, :created_at, :description, :transaction_type, :amount, :settlement_currency, :settlement_amount, :settlement_destination_type, :settlement_destination

    UPHOLD_CONTRIBUTION = "uphold_contribution".freeze
    UPHOLD_CONTRIBUTION_SETTLEMENT = "uphold_contribution_settlement".freeze
    CONTRIBUTION_SETTLEMENT = "contribution_settlement"
    REFERRAL_SETTLEMENT = "referral_settlement"

    def fee?
      transaction_type == "fees"
    end

    def eyeshade_settlement?
      transaction_type == CONTRIBUTION_SETTLEMENT || transaction_type == REFERRAL_SETTLEMENT
    end

    def uphold_contribution?
      transaction_type == UPHOLD_CONTRIBUTION_SETTLEMENT
    end

    def earning_period
      # If the transaction_type is from Eyeshade this means the period was for the previous month
      if eyeshade_settlement? || fee?
        created_at.prev_month.at_beginning_of_month.to_date
      else
        created_at.at_beginning_of_month.to_date
      end
    end
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
      transaction["channel"] = if account_identifier&.starts_with?(Publisher::OWNER_PREFIX)
        I18n.t("publishers.statements.index.account")
      elsif account_identifier.blank?
        "Manual"
      else
        channel_name(account_identifier)
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

    publisher.uphold_connection&.uphold_connection_for_channels&.each do |card_connection|
      # Refresh the cache, should only request the most recent page
      CacheUpholdTips.perform_now(uphold_connection_for_channel_id: card_connection.id)

      card_connection.cached_uphold_tips.find_each do |cached_tip|
        uphold << cached_tip.to_statement
      end
    end

    # Replicate the similar behavior of Eyeshade. Aggregates all the contribution amounts for the month, and puts them into one entry
    uphold.group_by { |u| u.created_at.at_end_of_month }.each do |date, entries|
      # Group by channels so we can show tips per channel
      entries.group_by { |e| e.channel }.each do |channel, channel_entries|
        # Finally group by currency, the currency can change in the middle of the month for direct tips but likely it will just be 1.
        channel_entries.group_by { |c| c.settlement_currency }.each do |currency, currency_entries|
          amount = currency_entries.sum { |x| x.amount }
          settlement_amount = currency_entries.sum { |x| x.settlement_amount }
          settlement_destination = currency_entries.detect { |x| x.settlement_destination }&.settlement_destination

          # We're specifying a negative amount because we group by transactions already paid out.
          # This gives us the ability to aggregate and show one Uphold transaction, rather than 300 or so tips that might have been sent.
          uphold << Statement.new(
            channel: channel,
            transaction_type: Statement::UPHOLD_CONTRIBUTION_SETTLEMENT,
            amount: -amount,
            settlement_currency: currency,
            settlement_amount: settlement_amount,
            settlement_destination: settlement_destination,
            created_at: date
          )
        end
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
