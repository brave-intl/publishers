# typed: false

require "test_helper"
require "webmock/minitest"
# require "mocha/test_unit"

class PayoutInProgressTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers
  include MockRewardsResponses

  before do
    stub_rewards_parameters
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

  test "Gemini generating in progress, referrer sees referrer message" do
    publisher = publishers(:gemini_completed)
    publisher.feature_flags[UserFeatureFlags::REFERRAL_ENABLED_OVERRIDE] = true
    publisher.save!
    sign_in publisher

    PublishersController.view_context_class.any_instance.stubs(:has_balance?).returns(true)
    visit home_publishers_path

    assert_content page, I18n.t("publishers.home_balances.payout_in_progress")
    assert_content page, I18n.t("publishers.home_balances.referral_payout_date")
  end

  test "Gemini generating in progress but no BAT so no payouts in progress" do
    publisher = publishers(:gemini_completed)

    sign_in publisher

    PublishersController.view_context_class.any_instance.stubs(:has_balance?).returns(false)
    visit home_publishers_path

    refute_content page, I18n.t("publishers.home_balances.payout_in_progress")
  end

  test "Gemini payout failed test" do
    # This test requires forgery protection in FF
    ActionController::Base.allow_forgery_protection = true
    publisher = publishers(:top_referrer_gemini)

    sign_in publisher

    visit home_publishers_path

    assert_content "We found an issue with the connection"
    ActionController::Base.allow_forgery_protection = false
  end

  test "Uphold payout failed test" do
    # This test requires forgery protection in FF
    ActionController::Base.allow_forgery_protection = true
    publisher = publishers(:top_referrer)
    wall = publisher.selected_wallet_provider
    wall.payout_failed = true
    wall.save!

    sign_in publisher
    visit home_publishers_path
    assert_content "We found an issue with the connection"
    ActionController::Base.allow_forgery_protection = false
  end

  test "Bitflyer payout failed test" do
    # This test requires forgery protection in FF
    ActionController::Base.allow_forgery_protection = true

    Capybara.using_driver(:firefox_ja) do
      publisher = publishers(:top_referrer_bitflyer)

      sign_in publisher

      visit home_publishers_path

      assert_content "アカウントへの接続に問題が見つかりました"
    end

    ActionController::Base.allow_forgery_protection = false
  end
end
