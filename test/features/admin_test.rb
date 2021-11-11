# typed: ignore
require "test_helper"

class AdminFeatureTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers

  let(:publisher) { publishers(:admin) }

  before do
    sign_in publisher
  end

  test "can view admin home" do
    visit admin_root_path
    assert_content page, "Contributions processed"
  end

  test "can view a creators payments" do
    visit admin_publisher_payments_path(publisher_id: publisher.id)
    assert_content page, "Earned To Date"
  end
end
