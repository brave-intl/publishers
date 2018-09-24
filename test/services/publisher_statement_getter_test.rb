require "test_helper"

class PublisherStatementGetterTest < ActiveJob::TestCase

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "has the correct request format" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)

    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/#{URI.escape(publisher.owner_identifier)}/transactions").
      to_return(status: 200, body: [].to_json, headers: {})

    # This will raise an error if the stubbed request format isn't correct
    PublisherStatementGetter.new(publisher: publisher, statement_period: "all").perform
  end

  test "filters transactions by period" do
    Rails.application.secrets[:api_eyeshade_offline] = true
    publisher = publishers(:verified) # Has one channel

    statement_data = PublisherStatementGetter.new(publisher: publisher, statement_period: "last_month").perform
    assert_equal 1, number_of_unique_settlement_dates(statement_data)

    statement_data = PublisherStatementGetter.new(publisher: publisher, statement_period: "this_month").perform
    assert_equal 1, number_of_unique_settlement_dates(statement_data)

    statement_data = PublisherStatementGetter.new(publisher: publisher, statement_period: "all").perform
    assert_equal PublisherTransactionsGetter::OFFLINE_NUMBER_OF_SETTLEMENTS, number_of_unique_settlement_dates(statement_data)
  end

  test "replaces channel identifiers with channel titles" do
    Rails.application.secrets[:api_eyeshade_offline] = true
    publisher = publishers(:uphold_connected)
    statement_data = PublisherStatementGetter.new(publisher: publisher, statement_period: "this_month").perform

    # Ensure all channel identifiers have been replaced
    statement_data.each do |transaction|
      assert_nil transaction["channel"].match("youtube#channel")
      assert_nil transaction["channel"].match("twitch#channel")
      assert_nil transaction["channel"].match("twitch#author")
      assert_nil transaction["channel"].match("twitter#channel")
    end
  end

  private

  def number_of_unique_settlement_dates(statement_data)
    num_different_settlement_dates = 0
    current_settlement_date = ""

    statement_data.each do |transaction|
      if transaction["created_at"] != current_settlement_date
        current_settlement_date = transaction["created_at"]
        num_different_settlement_dates += 1
      end
    end

    num_different_settlement_dates
  end
end
