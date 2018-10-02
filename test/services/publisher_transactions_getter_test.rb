require "test_helper"
require "eyeshade/balance"

class PublisherBalanceGetterTest < ActiveJob::TestCase

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "when offline gets transactions" do
    publisher = publishers(:uphold_connected)
    result = PublisherTransactionsGetter.new(publisher: publisher).perform_offline
    assert result.length > 0
    assert result.first["created_at"]
    assert result.first["description"]
    assert result.first["channel"]
    assert result.first["amount"]
    assert result.first["type"]
  end

  test "when online has the correct response format" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)

    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/#{URI.escape(publisher.owner_identifier)}/transactions").
      to_return(status: 200, body: ["fake_transaction_response"].to_json, headers: {})

    result = PublisherTransactionsGetter.new(publisher: publisher).perform
    assert_equal result.first, "fake_transaction_response"
  end
end
