require 'test_helper'
require "webmock/minitest"

class BrowserUsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    get browser_users_home_path
    assert_response :redirect
  end

  test "Browser user can access" do
    browser_user = publishers(:browser_user)
    sign_in browser_user

    get browser_users_home_path
    assert_response :success
  end
end
