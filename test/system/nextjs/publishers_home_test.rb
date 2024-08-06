require "application_system_test_case"
require "webmock/minitest"
require "test_helpers/nextjs_test_setup"

class PublishersHomeTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include EyeshadeHelper
  include Rails.application.routes.url_helpers
  include MockRewardsResponses
  include NextjsTestSetup

  let(:uphold_url) { Rails.configuration.pub_secrets[:uphold_api_uri] + "/v0/me" }
  before do
    setup_nextjs_test
    stub_rewards_parameters
    @prev_eyeshade_offline = Rails.configuration.pub_secrets[:api_eyeshade_offline]

    stub_request(:get, uphold_url).to_return(body: {status: "restricted", uphold_id: "123e4567-e89b-12d3-a456-426655440000", currencies: []}.to_json)
    # Mock out the creation of cards
    stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
    stub_request(:post, /cards/).to_return(body: {id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"}.to_json)
    stub_request(:get, /address/).to_return(body: [{formats: [{format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1"}], type: "anonymous"}].to_json)
  end

  after do
    Rails.configuration.pub_secrets[:api_eyeshade_offline] = @prev_eyeshade_offline
  end

  test "verified channel can be removed after confirmation" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_delete)

    sign_in_through_link publisher

    visit home_publishers_path

    assert_content page, channel.publication_title

    find("#channel_row_delete_button_#{channel.id}").click

    # TODO add this back in!
    # assert_content page, "Are you sure you want to remove this channel?"
    # find("[data-test-modal-container]").click_link("Remove")

    refute_content channel.publication_title
  end

  test "website channel type can be chosen" do
    publisher = publishers(:completed)
    sign_in_through_link publisher
    visit home_publishers_path

    page.find("#add-channel").click

    assert_content page, "Channels are accounts"
    assert_content page, "Website"
    assert_content page, "YouTube"

    page.find("#add-website").click

    assert_current_path(/site_channels\/new/)
  end

  test "dashboard can still load even when publisher's wallet cannot be fetched from eyeshade" do
    Rails.configuration.pub_secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in_through_link publisher

    wallet = {"wallet" => {"authorized" => false}}
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)
    visit home_publishers_path

    assert publisher.wallet.present?
  end

  test "dashboard can still load even when publisher's balance cannot be fetched from eyeshade" do
    prev_api_eyeshade_offline = Rails.configuration.pub_secrets[:api_eyeshade_offline]
    Rails.configuration.pub_secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)
    sign_in_through_link publisher

    wallet = {"wallet" => {"authorized" => false}}
    balances = "go away\nUser-agent: *\nDisallow:"

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, balances: balances)

    visit home_publishers_path

    refute publisher.wallet.present?
    assert_content page, "0 BAT"
  ensure
    Rails.configuration.pub_secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
  end
end
