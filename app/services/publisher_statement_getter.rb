class PublisherStatementGetter < BaseApiClient
  attr_reader :publisher
  attr_reader :statement_period

  def initialize(publisher:, statement_period:)
    @publisher = publisher
    @statement_period = statement_period
  end

  def perform
    transactions = PublisherTransactionsGetter.new(publisher: publisher).perform
    transactions = replace_channel_identifiers_with_channel_titles(transactions)
    transactions = filter_transactions_by_period(transactions, @statement_period)
    transactions
  end

  private

  def filter_transactions_by_period(transactions, period)
    case period
      when "all"
        transactions
      when "this_month"
        cutoff = Time.now.utc.at_beginning_of_month
        transactions.select { |transaction|
          transaction["created_at"].to_time.at_beginning_of_month.utc == cutoff
        }
      when "last_month"
        cutoff = (Time.now - 1.month).utc.at_beginning_of_month
        transactions.select { |transaction|
          transaction["created_at"].to_time.at_beginning_of_month.utc == cutoff
        }
      else
        transactions
    end
  end

  def replace_channel_identifiers_with_channel_titles(transactions)
    transactions.map { |transaction|
      channel_identifier = transaction["channel"]
      channel = Channel.find_by_channel_identifier(channel_identifier)
      transaction["channel"] = channel.publication_title
      transaction
    }
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
