require 'test_helper'
require 'webmock/minitest'

class CreateUpholdCardsJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  test "creates default currency card if default currency is possible but not available" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:uphold_connected)
      publisher.default_currency = "BAT"
      publisher.save!

      # stub wallet response
      wallet = { "wallet" => { "defaultCurrency" => "USD",
                               "authorized" => true,
                               "availableCurrencies" => "",
                               "possibleCurrencies" => "BAT",
                               "scope" => "cards:read, cards:write, user:read" }
      }.to_json

      # stub wallet response
      stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
        to_return(status: 200, body: wallet, headers: {})

      # stub balances response
      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
        to_return(status: 200, body: [].to_json)

      # ensures the PublisherWalletGetter does not fail for the per channel balances belonging to this fixture.
      CreateUpholdCardsJob.perform_now(publisher_id: publisher.id)

      # ensure request to create BAT card was made
      assert_requested :post,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v3/owners/#{URI.escape(publisher.owner_identifier)}/wallet/card",
        body: '{"currency":"BAT","label":"Brave Payments"}',
        times: 1

      # ensure only one request to update eyeshade default currency was made
      assert_requested :patch,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet",
        times: 1

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "does not create default currency card if default currency is available" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:uphold_connected)
      publisher.default_currency = "BAT"
      publisher.save!

      # stub wallet response
      wallet = { "wallet" => { "defaultCurrency" => "USD",
                               "authorized" => true,
                               "availableCurrencies" => "BAT",
                               "possibleCurrencies" => "BAT",
                               "scope" => "cards:read, cards:write, user:read" }
      }.to_json

      # stub wallet response
      stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
        to_return(status: 200, body: wallet, headers: {})

      # stub balances response
      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
        to_return(status: 200, body: [].to_json)

      CreateUpholdCardsJob.perform_now(publisher_id: publisher.id)

      # ensure request to create BAT card was not made
      assert_requested :post,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v3/owners/#{URI.escape(publisher.owner_identifier)}/wallet/card",
        body: '{"currency":"BAT","label":"Brave Payments"}',
        times: 0

      # ensure only one request to update eyeshade default currency was made
      assert_requested :patch,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet",
        times: 1

      # ensure request to update eyeshade default currency was made
      assert_requested :patch,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet",
        body: '{
  "defaultCurrency": "BAT" 
}
'
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "creates BAT card if default currency is not BAT, but BAT is possible" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:uphold_connected)
      publisher.default_currency = "LOL"
      publisher.save!

      # stub wallet response
      wallet = { "wallet" => { "defaultCurrency" => "USD",
                               "authorized" => true,
                               "availableCurrencies" => "",
                               "possibleCurrencies" => "BAT,LOL",
                               "scope" => "cards:read, cards:write, user:read" }
      }.to_json

      # stub wallet response
      stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
        to_return(status: 200, body: wallet, headers: {})

      # stub balances response
      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
        to_return(status: 200, body: [].to_json)

      CreateUpholdCardsJob.perform_now(publisher_id: publisher.id)

      # ensure request to create BAT card was made
      assert_requested :post,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v3/owners/#{URI.escape(publisher.owner_identifier)}/wallet/card",
        body: '{"currency":"BAT","label":"Brave Payments"}',
        times: 1

      # ensure request to create LOL card was made
      assert_requested :post,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v3/owners/#{URI.escape(publisher.owner_identifier)}/wallet/card",
        body: '{"currency":"LOL","label":"Brave Payments"}',
        times: 1

      # ensure only one request to update eyeshade default currency was made
      assert_requested :patch,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet",
        times: 1
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "does not create BAT card if default currency is BAT" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:uphold_connected)
      publisher.default_currency = "BAT"
      publisher.save!

      # stub wallet response
      wallet = { "wallet" => { "defaultCurrency" => "BAT",
                               "authorized" => true,
                               "availableCurrencies" => "BAT",
                               "possibleCurrencies" => "BAT,LOL",
                               "scope" => "cards:read, cards:write, user:read" }
      }.to_json

      # stub wallet response
      stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
        to_return(status: 200, body: wallet, headers: {})

      # stub balances response
      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
        to_return(status: 200, body: [].to_json)

      CreateUpholdCardsJob.perform_now(publisher_id: publisher.id)

      # ensure request to create LOL card was made
      assert_requested :post,
        "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v3/owners/#{URI.escape(publisher.owner_identifier)}/wallet/card",
        times: 0
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end