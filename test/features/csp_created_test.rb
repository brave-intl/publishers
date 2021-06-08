require "test_helper"
require "webmock/minitest"

class CspCreatedTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers

  test "it creates violations" do
    CspViolationReport.destroy_all
    publisher = publishers(:small_media_group)
    sign_in publisher
    assert_changes 'CspViolationReport.count' do
      visit home_publishers_path
    end
  end
end
