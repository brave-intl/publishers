require "test_helper"
require "webmock/minitest"

class PublisherStatement::GetterTest < ActiveJob::TestCase
  test "when offline returns true" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:verified)

      publisher_statement = PublisherStatement.new(
        publisher: publisher,
        period: :all,
        source_url: 'example.com')

      result = PublisherStatement::Getter.new(publisher_statement: publisher_statement).perform

      assert_equal "Fake offline data", result

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online returns the response document received by fetching source_url" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      stub_request(:get, /report\/123/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: "Fake", headers: {})

      publisher = publishers(:verified)

      publisher_statement = PublisherStatement.new(
        publisher: publisher,
        period: :all,
        source_url: '/report/123')

      result = PublisherStatement::Getter.new(publisher_statement: publisher_statement).perform
      assert_equal "Fake", result

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "when online returns nil if fetching source_url returns a 404" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      stub_request(:get, /report\/123/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 404, headers: {})

      publisher = publishers(:verified)

      publisher_statement = PublisherStatement.new(
        publisher: publisher,
        period: :all,
        source_url: '/report/123')

      result = PublisherStatement::Getter.new(publisher_statement: publisher_statement).perform
      assert_nil result

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end
