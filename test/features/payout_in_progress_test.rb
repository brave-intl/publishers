require "test_helper"
require "webmock/minitest"
require 'mocha/test_unit'

class PayoutInProgressTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers

  before do
    SetPayoutsInProgressJob.perform_now
  end

  after do
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
