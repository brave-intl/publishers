# Ask Eyeshade to generate a publisher statement since the earliest created by month
class PublisherStatement::FetchAll < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:, created_by_admin: true)
    @publisher = publisher
    @created_by_admin = created_by_admin
    @publisher_statement_ids = []
  end

  def perform
    load_statements
    PublisherStatement.where(id: @publisher_statement_ids)
  end

  def stringify
    # Read out from CSVs into JSON
    PublisherStatement.where(id: @publisher_statement_ids).find_each do |publisher_statement|
      # TODO
    end
  end

  private

  def load_statements
    iterative_date_date = Publisher.channels.order(created_at: :asc).first.created_at.utc.beginning_of_month
    todays_date = Time.now.utc.to_date
    while iterative_date.end_of_month < todays_date
      # (Albert Wang): TODO This will change due to an updated API.
      publisher_statement = PublisherStatement.find_by(period: formatted_period(iterative_date, todays_date))
      @publisher_statement_ids << publisher_statement.present? ? publisher_statement.id : PublisherStatement::Generator.new(publisher: @publisher, statement_period: nil, starting: iterative_date, ending: iterative_date.end_of_month).perform
    end
  end

  def formatted_period(starting_date, todays_date)
    starting_date.strftime("%Y-%m") + '_' + ending_date.strftime("%Y-%m")
  end
end
