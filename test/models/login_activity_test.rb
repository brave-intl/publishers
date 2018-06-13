require "test_helper"

class LoginActivityTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test "gets the latest login activity" do
    publisher = publishers(:verified)
    assert publisher.valid?

    assert_equal "Googlebot", publisher.last_login_activity.user_agent
  end
end