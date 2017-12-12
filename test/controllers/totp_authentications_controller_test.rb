require 'test_helper'

class TotpAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "TOTP Authentication creation when pending_2fa_current_publisher_id" do
    publisher = publishers(:completed)
    registration = totp_registrations(:default)
    publisher.update_attribute(:totp_registration, registration)

    visit_authentication_url publisher
    assert_redirected_to two_factor_authentications_path, "precond - visiting authentication url redirects to 2fa page"

    ROTP::TOTP.any_instance.stubs(:verify_with_drift_and_prior).returns(Time.now.to_i)

    post totp_authentications_path, params: {
      totp_password: '123456'
    }

    assert_redirected_to home_publishers_path, "after 2fa post user is directed to the home path"
  end

  test "TOTP Authentication creation error when pending_2fa_current_publisher_id" do
    publisher = publishers(:completed)
    registration = totp_registrations(:default)
    publisher.update_attribute(:totp_registration, registration)

    visit_authentication_url publisher
    assert_redirected_to two_factor_authentications_path, "precond - visiting authentication url redirects to 2fa page"

    ROTP::TOTP.any_instance.stubs(:verify_with_drift_and_prior).returns(false)

    post totp_authentications_path, params: {
      totp_password: '123456'
    }

    assert_redirected_to two_factor_authentications_path(request_totp: true), "error redirects to 2fa authentication forcing totp"
  end
end
