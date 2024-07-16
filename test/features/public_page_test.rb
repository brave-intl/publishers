# typed: false

require "test_helper"
require "webmock/minitest"
require "vcr"

class PublicPageTest < Capybara::Rails::TestCase
  include ActionMailer::TestHelper
  include Rails.application.routes.url_helpers

  def setup
    ActionController::Base.allow_forgery_protection = true
  end

  def teardown
    ActionController::Base.allow_forgery_protection = false
  end

  test "redirects to home page if channel identifier not found" do
    visit public_channel_path(public_identifier: "107zsxjfg6")
    assert_content page, "Earn for your online content"
  end

  test "can display description and title" do
    VCR.use_cassette("test_can_display_description_and_title") do
      visit public_channel_path(public_identifier: "123456dfg6")
      assert_content page, "Channel Banner"
      assert_content page, "Lorem Ipsum"
      assert_content page, "Show your love and send a token of your gratitude"
    end
  end

  test "can select different currencies" do
    VCR.use_cassette("test_can_select_different_currencies") do
      visit public_channel_path(public_identifier: "123456dfg6")
      assert_content page, "20.87683 BAT"
      find(".crypto-currency-dropdown", text: "ERC-20 BAT").click
      find("#react-select-2-option-1-0", text: "Solana").click
      assert_content page, "0.0282 SOL"
    end
  end

  test "can update amounts" do
    VCR.use_cassette("test_can_update_amounts") do
      visit public_channel_path(public_identifier: "123456dfg6")
      assert_content page, "20.87683 BAT"
      find("button", text: "$10").click
      assert_content page, "41.75365 BAT"
    end
  end
end
