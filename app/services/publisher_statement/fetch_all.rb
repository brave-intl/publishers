# Ask Eyeshade to generate a publisher statement since the earliest created by month
require 'net/http'
require 'net/https'
require 'json'
require 'csv'
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

  def perform_and_stringify
    load_statements
    results = []
    # Read out from CSVs into JSON
    PublisherStatement.where(id: @publisher_statement_ids).find_each do |publisher_statement|
      if Rails.env.test? || Rails.env.development?
        results.append({channel_statements: mock_publisher_statement_values}.merge({month: publisher_statement.period.split("-")[0..1].join("-")}))
      else
        result = CSV.read(retrieve_payload(publisher_statement.source_url))
        keys = result[0]
        results.append({channel_statements: CSV.parse(result[1..-1]).map {|a| Hash[ keys.zip(a) ] }}.merge({month: publisher_statement.period}))

      end
    end
    results
  end

  private

  def mock_publisher_statement_values
    [
      {
        note: "Finalized referrals",
        timestamp: nil,
        publisher: "yachtcaptain23 <https://www.youtube.com/channel/UC_3xPuguXslZl-AUWXGkgIA>",
        currency: nil,
        amount: nil,
        BAT: "1234.567821167503675983",
        'BAT fees' => "80.975616903552825051"
      },
      {
        note: "Finalized referrals",
        timestamp: nil,
        publisher: "yachtcaptain23 <yachtcaptain23.github.io>",
        currency: nil,
        amount: nil,
        BAT: "1234.8080808080",
        'BAT fees' => "10.0000000000"
      }
    ]
  end

  def retrieve_payload(source_url)
    uri = URI(source_url)

    # Create client
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    # Create Request
    req =  Net::HTTP::Post.new(uri)

    # Add headers
    req.add_field "Content-Type", "application/json; charset=utf-8"

    # Fetch Request
    http.request(req)
  end

  def load_statements
    iterative_date = @publisher.channels.order(created_at: :asc).first.created_at.utc.beginning_of_month
    todays_date = Time.now.utc.to_date
    while iterative_date.end_of_month < todays_date
      # (Albert Wang): TODO This will change due to an updated API.
      publisher_statement = PublisherStatement.find_by(period: formatted_period(iterative_date, todays_date))
      @publisher_statement_ids.append(publisher_statement.present? ? publisher_statement.id : PublisherStatement::Generator.new(publisher: @publisher, statement_period: formatted_period(iterative_date, iterative_date.end_of_month), starting: iterative_date, ending: iterative_date.end_of_month).perform)
      iterative_date = iterative_date.next_month
    end
  end

  def formatted_period(starting_date, ending_date)
    starting_date.strftime("%Y-%m-%d") + '_' + ending_date.strftime("%Y-%m-%d")
  end
end
