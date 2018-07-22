# Ask Eyeshade to generate a publisher statement.
class PublisherStatement::Generator < BaseApiClient
  attr_reader :publisher
  attr_reader :statement_period
  attr_accessor :starting, :ending

  def initialize(publisher:, statement_period:, created_by_admin: false, starting: nil, ending: nil, hidden: false)
    @publisher = publisher
    @statement_period = statement_period
    @created_by_admin = created_by_admin
    @starting = starting
    @ending = ending
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/statement#{query_params}")
    end

    statement = PublisherStatement.new(
      publisher: @publisher,
      period: @statement_period,
      source_url: JSON.parse(response.body)["reportURL"],
      created_by_admin: @created_by_admin)

    statement.save!

    return statement
  end

  def perform_offline
    fake_report = "/assets/fake_statement.csv#{query_params}"

    Rails.logger.info("PublisherStatement::Generator eyeshade offline; generating fake report: #{fake_report}")

    statement = PublisherStatement.new(
      publisher: @publisher,
      period: @statement_period,
      source_url: fake_report,
      created_by_admin: @created_by_admin)

    statement.save!

    return statement
  end

  def query_params
    starting ||= statement_period_start
    ending ||= statement_period_end

    if starting || ending
      qps = []
      qps << "starting=#{starting.iso8601}" if starting
      qps << "ending=#{ending.iso8601}" if ending
      return "?#{qps.join('&')}"
    end
  end

  private

  def statement_period_start
    case @statement_period
    when :past_7_days
      Date.today - 7
    when :past_30_days
      Date.today - 30
    when :this_month
      Date.today.beginning_of_month
    when :last_month
      (Date.today - 1.month).beginning_of_month
    when :this_year
      Date.today.beginning_of_year
    when :last_year
      (Date.today - 1.year).beginning_of_year
    when :all
      nil
    end
  end

  def statement_period_end
    case @statement_period
    when :past_7_days
      Date.today
    when :past_30_days
      Date.today
    when :this_month
      Date.today.end_of_month
    when :last_month
      (Date.today - 1.month).end_of_month
    when :this_year
      Date.today.end_of_year
    when :last_year
      (Date.today - 1.year).end_of_year
    when :all
      nil
    end
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
