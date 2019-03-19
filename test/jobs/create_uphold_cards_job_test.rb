require 'test_helper'
require 'webmock/minitest'

class CreateUpholdCardsJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper
  include EyeshadeHelper

  before(:example) do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
  end

  test "creates default currency card if wallet address missing" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:uphold_connected)
    publisher.default_currency = "BAT"
    publisher.save!

    # stub wallet response
    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => true,
                             "isMember" => true,
                             "status" => "ok",
                             "availableCurrencies" => "",
                             "possibleCurrencies" => "BAT",
                             "scope" => "cards:read, cards:write, user:read",
                           },
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    CreateUpholdCardsJob.perform_now(publisher_id: publisher.id)

    # ensure request to create BAT card was made
    assert_requested :post,
      "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v3/owners/#{URI.escape(publisher.owner_identifier)}/wallet/card",
      body: '{"currency":"BAT","label":"Brave Rewards"}',
      times: 1

    # ensure only one request to update eyeshade default currency was made
    assert_requested :patch,
      "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet",
      times: 1
  end

  test "does not create default currency card if wallet address present" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:uphold_connected)
    publisher.default_currency = "BAT"
    publisher.save!

    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => true,
                             "isMember" => true,
                             "status" => "ok",
                             "availableCurrencies" => "BAT",
                             "possibleCurrencies" => "BAT",
                             "scope" => "cards:read, cards:write, user:read",
                             "address" => "cc053a27-cdcd-4fdb-aa90-f0417df26242"
                           },
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    CreateUpholdCardsJob.perform_now(publisher_id: publisher.id)

    # ensure request to create BAT card was not made
    assert_requested :post,
      "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v3/owners/#{URI.escape(publisher.owner_identifier)}/wallet/card",
      body: '{"currency":"BAT","label":"Brave Rewards"}',
      times: 0

    # ensure only one request to update eyeshade default currency was made
    assert_requested :patch,
      "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet",
      body: "{\n  \"defaultCurrency\": \"BAT\" \n}\n",
      times: 1
  end
end
