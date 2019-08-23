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
          channels[account_identifier] = Channel.find_by_channel_identifier(account_identifier)
          channel = channels[account_identifier]
        end
        transaction["channel"] = channel&.publication_title || account_identifier
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

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
