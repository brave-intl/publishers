# typed: false

require "test_helper"

class AdminFeatureTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers
  include MockRewardsResponses

  let(:publisher) { publishers(:admin) }

  before do
    sign_in publisher
    stub_rewards_parameters
  end

  test "can view admin home" do
    visit admin_root_path
    assert_content page, "Publishers"
  end

  test "can view a creators payments" do
    visit admin_publisher_payments_path(publisher_id: publisher.id)
    assert_content page, "Earned To Date"
  end
end
