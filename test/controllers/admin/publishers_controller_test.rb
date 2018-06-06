require 'test_helper'
require "webmock/minitest"

class Admin::PublishersControllerTest < ActionDispatch::IntegrationTest
  # For Devise >= 4.1.1
  include Devise::Test::IntegrationHelpers
  # Use the following instead if you are on Devise <= 4.1.0
  # include Devise::TestHelpers

  test 'regular users cannot access' do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) {
      get admin_publishers_path
    }
  end

  test 'admin can access' do
    admin = publishers(:admin)
    sign_in admin

    get admin_publishers_path
    assert_response :success
  end
end
