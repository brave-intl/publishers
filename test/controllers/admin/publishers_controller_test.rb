require 'test_helper'
require "webmock/minitest"

class Admin::PublishersControllerTest < ActionDispatch::IntegrationTest
  # For Devise >= 4.1.1
  include Devise::Test::IntegrationHelpers
  # Use the following instead if you are on Devise <= 4.1.0
  # include Devise::TestHelpers

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) {
      get admin_publishers_path
    }
  end

  test "admin can access" do
    admin = publishers(:admin)
    sign_in admin

    get admin_publishers_path
    assert_response :success
  end

  test "raises error unless admin has 2fa enabled" do
    admin = publishers(:admin)
    admin.totp_registration.destroy! # remove 2fa
    admin.reload
    sign_in admin

    assert_raises(Ability::TwoFactorDisabledError) do
      get admin_publishers_path
    end
  end

  test "raises error unless admin is on admin whitelist" do
    class ActionDispatch::Request #rails 2: ActionController::Request
      def remote_ip
        '1.2.3.4' # not on whitelist
      end
    end

    admin = publishers(:admin)
    sign_in admin

    assert_raises(Ability::AdminNotOnIPWhitelistError) do
      get admin_publishers_path
    end
  end
end
