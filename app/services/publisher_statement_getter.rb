class PublisherStatementGetter < BaseApiClient
  attr_reader :publisher
  attr_reader :statement_period

  def initialize(publisher:, statement_period:)
    @publisher = publisher
    @statement_period = statement_period
  end

  def perform
    transactions = PublisherTransactionsGetter.new(publisher: publisher).perform
    transactions = replace_account_identifiers_with_titles(transactions)
    transactions = filter_transactions_by_period(transactions, @statement_period)
    transactions
  end

  private

  def filter_transactions_by_period(transactions, period)
    case period
      when "all"
        transactions
      when "this_month"
        cutoff = Date.today.beginning_of_month
        transactions.select { |transaction|
          transaction["created_at"].to_date.at_beginning_of_month == cutoff
        }
      when "last_month"
        cutoff = (Date.today - 1.month).at_beginning_of_month
        transactions.select { |transaction|
          transaction["created_at"].to_date.at_beginning_of_month == cutoff
        }
      else
        transactions
    end
  end

  def replace_account_identifiers_with_titles(transactions)
    transactions.map { |transaction|
      account_identifier = transaction["channel"]
      if account_identifier.starts_with?(Publisher::OWNER_PREFIX)
        transaction["channel"] = "All"
      else
        channel = Channel.find_by_channel_identifier(account_identifier)
        transaction["channel"] = channel.publication_title
      end
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
