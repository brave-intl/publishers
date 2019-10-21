require "test_helper"
require "webmock/minitest"

class PublishersHomeTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include EyeshadeHelper

  let(:uphold_url) { Rails.application.secrets[:uphold_api_uri] + "/v0/me" }
  before do
    @prev_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]

    stub_request(:get, uphold_url).to_return(body: { status: "restricted", uphold_id: "123e4567-e89b-12d3-a456-426655440000", currencies: [] }.to_json)
    # Mock out the creation of cards
    stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
    stub_request(:post, /cards/).to_return(body: { id: "fb25048b-79df-4e64-9c4e-def07c8f5c04" }.to_json)
    stub_request(:get, /address/).to_return(body: [{ formats: [{ format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1" }], type: "anonymous" }].to_json)
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_eyeshade_offline
  end

  # TODO Uncomment when channel removal is enabled
  # test "unverified channel can be removed after confirmation" do
  #   publisher = publishers(:small_media_group)
  #   channel = channels(:small_media_group_to_verify)

  #   sign_in publisher
  #   visit home_publishers_path

  #   assert_content page, channel.publication_title
  #   find("#channel_row_#{channel.id}").click_link('Remove Channel')
  #   assert_content page, "Are you sure you want to remove this channel?"
  #   find('[data-test-modal-container]').click_link("Remove Channel")
  #   refute_content page, channel.publication_title
  # end

  test "verified channel can be removed after confirmation" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_delete)

    sign_in publisher
    visit home_publishers_path

    assert_content page, channel.publication_title
    find("#channel_row_#{channel.id}").click_link('Remove channel')
    assert_content page, "Are you sure you want to remove this channel?"
    find('[data-test-modal-container]').click_link("Remove Channel")
    wait_until { !page.find('.cssload-container', visible: :all).visible? }
    refute_content channel.publication_title
  end

  test "website channel type can be chosen" do
    publisher = publishers(:completed)
    sign_in publisher
    visit home_publishers_path

    click_link('+ Add Channel', match: :first)

    assert_content page, 'Add Channel'
    assert_content page, 'Website'
    assert_content page, 'YouTube'

    find('[data-test-choose-channel-website]').click

    assert_current_path(/site_channels\/new/)
  end

  test "confirm default currency modal appears after uphold signup" do
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    visit home_publishers_path
    assert_content page, I18n.t("publishers.confirm_default_currency_modal.headline")
  end

  test "confirm default currency modal does not appear for non uphold verified publishers" do
    publisher = publishers(:completed)
    sign_in publisher

    visit home_publishers_path
    refute_content page, I18n.t("publishers.confirm_default_currency_modal.headline")
  end

  test "confirm default currency modal does not appear for non uphold authorized publishers" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:completed)
    sign_in publisher

    wallet = { "wallet" => { "authorized" => false }}
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    visit home_publishers_path
    refute_content page, I18n.t("publishers.confirm_default_currency_modal.headline")
  end

  test "dashboard can still load even when publisher's wallet cannot be fetched from eyeshade" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    wallet = { "wallet" => { "authorized" => false } }
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)
    visit home_publishers_path

    assert publisher.wallet.present?
  end

  test "dashboard can still load even when publisher's balance cannot be fetched from eyeshade" do
    begin
      prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
      Rails.application.secrets[:api_eyeshade_offline] = false
      publisher = publishers(:uphold_connected)
      sign_in publisher

      wallet = { "wallet" => { "authorized" => false } }
      balances = "go away\nUser-agent: *\nDisallow:"

      stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, balances: balances)

      visit home_publishers_path

      refute publisher.wallet.present?
      assert_content page, "Unavailable"
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end
