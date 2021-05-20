require "test_helper"

class PublisherBalanceGetterTest < ActiveJob::TestCase
  describe "mocked transactions" do
    before(:example) do
      @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:uphold_connected)
      @mocked_response = PublisherTransactionsGetter.new(publisher: publisher).perform_offline

      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/#{URI.encode_www_form_component(publisher.owner_identifier)}/transactions").
        to_return(status: 200, body: @mocked_response.to_json, headers: {})

      @transactions = PublisherTransactionsGetter.new(publisher: publisher).perform
    end

    after(:example) do
      Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
    end

    test "has the right keys" do
      keys = @transactions.first.keys
      ["created_at", "description", "channel", "amount", "transaction_type", "from_account", "to_account"].each do |key|
        assert keys.include?(key)
      end
    end

    test "removes the referral depreciation transaction" do
      assert_not_empty @mocked_response.select { |transaction| transaction['to_account'] == PublisherTransactionsGetter::REFERRAL_DEPRECIATION_ACCOUNT }
      assert_empty @transactions.select { |transaction| transaction['to_account'] == PublisherTransactionsGetter::REFERRAL_DEPRECIATION_ACCOUNT }
    end
  end
end
