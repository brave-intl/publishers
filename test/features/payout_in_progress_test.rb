require "test_helper"
require "webmock/minitest"
require "mocha/test_unit"

class PayoutInProgressTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers

  before do
    SetPayoutsInProgressJob.perform_now
  end

  after do
    # Turn payouts off
    Rails.cache.write(SetPayoutsInProgressJob::PAYOUTS_IN_PROGRESS, SetPayoutsInProgressJob::CONNECTIONS.collect { |connection| [connection, false] }.to_h)
  end

  test "Gemini generating in progress" do
    publisher = publishers(:gemini_completed)

    sign_in publisher

    PublishersController.view_context_class.any_instance.stubs(:has_balance?).returns(true)
    visit home_publishers_path

    assert_content page, I18n.t("publishers.home_balances.payout_in_progress")
  end

  test "Gemini generating in progress but no BAT so no payouts in progress" do
    publisher = publishers(:gemini_completed)

    sign_in publisher

    PublishersController.view_context_class.any_instance.stubs(:has_balance?).returns(false)
    visit home_publishers_path

    refute_content page, I18n.t("publishers.home_balances.payout_in_progress")
  end
end
