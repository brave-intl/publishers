require 'test_helper'

class PublishersControllerTest < ActionController::TestCase
  # For Devise >= 4.1.1
  include Devise::Test::IntegrationHelpers
  # Use the following instead if you are on Devise <= 4.1.0
  # include Devise::TestHelpers

  test 'regular users cannot access' do
    publisher = publishers(:completed)
    sign_in publisher

    get :index
    assert_response :failure
  end

  test 'admin can access' do
    admin = publishers(:admin)
    sign_in admin

    get :index
    assert_response :success
  end
end
