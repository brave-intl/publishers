require "test_helper"
require "webmock/minitest"
require 'mocha/test_unit'

class PayoutInProgressTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include EyeshadeHelper
  include Rails.application.routes.url_helpers

  let(:uphold_url) { Rails.application.secrets[:uphold_api_uri] + "/v0/me" }
  before do
    @prev_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    SetPayoutsInProgressJob.perform_now

    stub_request(:get, uphold_url).to_return(body: { status: "restricted", uphold_id: "123e4567-e89b-12d3-a456-426655440000", currencies: [] }.to_json)
    # Mock out the creation of cards
    stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
    stub_request(:post, /cards/).to_return(body: { id: "fb25048b-79df-4e64-9c4e-def07c8f5c04" }.to_json)
    stub_request(:get, /address/).to_return(body: [{ formats: [{ format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1" }], type: "anonymous" }].to_json)
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_eyeshade_offline

    # Turn payouts off
    Rails.cache.write(SetPayoutsInProgressJob::PAYOUTS_IN_PROGRESS, Hash[SetPayoutsInProgressJob::CONNECTIONS.collect { |connection| [connection, false] }])
  end

  test "Gemini generating in progress" do
    publisher = publishers(:gemini_completed)

    sign_in publisher
    visit home_publishers_path

    assert_content page, I18n.t("publishers.home_balances.payout_in_progress")
    assert_content page, I18n.t("publishers.payout_status.information.generating")
  end

  test "Uphold creator doesn't have enough" do
    publisher = publishers(:uphold_connected_currency_unconfirmed)

    sign_in publisher
    visit home_publishers_path

    assert_content page, I18n.t("publishers.home_balances.payout_minimum_balance", amount: PayoutReport::MINIMUM_BALANCE_AMOUNT)
  end

  test "Uphold creator has enough and gets message explaining minimums across channels" do
    publisher = publishers(:uphold_connected_currency_unconfirmed)

    sign_in publisher

    PublishersController.view_context_class.any_instance.expects(:qualifies_for_payout?).returns(true)
    visit home_publishers_path

    assert_content page, I18n.t("publishers.home_balances.payout_in_progress_uphold", amount: PayoutReport::MINIMUM_BALANCE_AMOUNT)
  end
end
