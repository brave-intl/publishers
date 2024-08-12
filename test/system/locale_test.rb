require "application_system_test_case"

class LocaleTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers
  include MockRewardsResponses

  before do
    stub_rewards_parameters
    publisher = publishers(:small_media_group)
    sign_in publisher
  end

  test "login with EN accept language and no locale shows english" do
    visit home_publishers_path
    assert_content page, "Add Channel"
  end

  test "login with EN accept language and JA locale shows Japanese" do
    visit home_publishers_path(locale: "ja")
    assert_content page, "チャンネルを追加"
  end

  test "login with JA accept language and no locale shows Japanese" do
    Capybara.using_driver(:rack_test_jp) do
      visit home_publishers_path
      assert_content page, "チャンネルを追加"
    end
  end

  test "login with JA accept language and EN locale shows Japanese" do
    Capybara.using_driver(:rack_test_jp) do
      visit home_publishers_path(locale: "EN")
      assert_content page, "チャンネルを追加"
    end
  end
end
