class PublisherStatementGetter < BaseApiClient
  attr_reader :publisher_statement

  def initialize(publisher_statement:)
    @publisher_statement = publisher_statement
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url(@publisher_statement.source_url)
    end
    response.body
  rescue Faraday::Error => e
    Rails.logger.warn("PublisherStatementGetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherStatementGetter offline.")
    'Fake offline data'
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
