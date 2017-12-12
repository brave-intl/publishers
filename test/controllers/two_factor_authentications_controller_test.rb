require 'test_helper'

class TwoFactorAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "2FA page requires pending_2fa_current_publisher_id" do
    get(two_factor_authentications_path)
    assert_redirected_to(root_path)
  end

  test "2FA page renders when pending_2fa_current_publisher_id and U2F registrations" do
    publisher = publishers(:completed)
    publisher.u2f_registrations << u2f_registrations(:default)

    visit_authentication_url publisher
    assert_redirected_to two_factor_authentications_path

    follow_redirect!
    assert_select("input[name=u2f_app_id][value=?]", @controller.u2f.app_id)
    assert_select("input[name=u2f_challenge][value]")
    # This field has a JSON array values
    assert_select("input[name=u2f_sign_requests][value^='[']")
    # Check that response field is provided but not assigned a value
    assert_select("input[name=u2f_response]:not([value])")
  end

  test "TOTP page renders when pending_2fa_current_publisher_id and TOTP registration" do
    publisher = publishers(:completed)
    registration = totp_registrations(:default)
    publisher.update_attribute(:totp_registration, registration)

    visit_authentication_url publisher
    assert_redirected_to two_factor_authentications_path

    follow_redirect!
    # Check that response field is provided but not assigned a value
    assert_select("input[name=totp_password]:not([value])")
  end
end
