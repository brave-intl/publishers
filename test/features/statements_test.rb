# typed: false

require "test_helper"

class StatementTest < Capybara::Rails::TestCase
  include ActionMailer::TestHelper
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

  test "statements page doesnt show uphold message for gemini user" do
    publisher = publishers(:gemini_completed)
    sign_in publisher

    visit statements_path
    refute_content page, I18n.t("publishers.statements.index.missing_scope")
  end

  test "statements page shows uphold message for uphold user" do
    publisher = publishers(:uphold_connected)
    sign_in publisher

    visit statements_path
    assert_content page, I18n.t("publishers.statements.index.missing_scope")
  end
end
