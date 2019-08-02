require 'test_helper'
require 'webmock/minitest'

class CreateUpholdCardsJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper
  include EyeshadeHelper

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    stub_request(:get, Rails.application.secrets[:uphold_api_uri] + "/v0/me/cards?q=currency:USD").to_return(body: [].to_json)
    stub_request(:post, Rails.application.secrets[:uphold_api_uri] + "/v0/me/cards").to_return(body: {id: '123e4567-e89b-12d3-a456-426655440000'}.to_json)
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "creates default currency card if wallet address missing" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:uphold_connected_details)
    publisher.default_currency = "BAT"
    publisher.save!

    # stub wallet response
    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => true,
                             "isMember" => true,
                             "status" => "ok",
                             "possibleCurrencies" => "BAT",
                             "scope" => "cards:read, cards:write, user:read",
                           },
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    CreateUpholdCardsJob.perform_now(uphold_connection_id: publisher.uphold_connection.id)
    publisher.uphold_connection.reload

    assert_equal publisher.uphold_connection.address, '123e4567-e89b-12d3-a456-426655440000'
  end

  test "does not create default currency card if wallet address present" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:uphold_connected_details)
    publisher.default_currency = "BAT"
    publisher.save!

    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => true,
                             "isMember" => true,
                             "status" => "ok",
                             "possibleCurrencies" => "BAT",
                             "scope" => "cards:read, cards:write, user:read",
                             "address" => "cc053a27-cdcd-4fdb-aa90-f0417df26242"
                           },
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    CreateUpholdCardsJob.perform_now(uphold_connection_id: publisher.uphold_connection.id)
    publisher.uphold_connection.reload

    assert_equal publisher.uphold_connection.address, '123e4567-e89b-12d3-a456-426655440000'
  end
end
