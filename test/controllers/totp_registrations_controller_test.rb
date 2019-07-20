require "test_helper"

class TotpRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "new requires authentication" do
    get new_totp_registration_path
    assert_redirected_to root_path
  end

  test "new renders when authenticated with new key form" do
    sign_in publishers(:completed)
    get new_totp_registration_path

    assert_response :success
    assert_select "form[method=post][action=?]", totp_registrations_path do
      assert_select "input[name=totp_password]:not([value])"
      assert_select "input[type=submit]"
    end
  end

  test "new renders when authenticated and reconfiguring with new key form and warning" do
    publisher = publishers(:completed)
    totp_registration = totp_registrations(:default)
    publisher.update_attribute(:totp_registration, totp_registration)

    sign_in publisher
    get new_totp_registration_path

    assert_response :success
    assert_select "form[method=post][action=?]", totp_registrations_path do
      assert_select "input[name=totp_password]:not([value])"
      assert_select "input[type=submit]"
    end
    assert_match "Reconfiguring will invalidate your existing authentication code devices", response.body
  end

  test "TOTP registration creation" do
    sign_in publishers(:completed)

    ROTP::TOTP.any_instance.stubs(:verify_with_drift).returns(true)

    assert_difference("TotpRegistration.count") do
      post totp_registrations_path, params: {
        totp_password: "123456",
        totp_registration: { secret: ROTP::Base32.random_base32 }
      }
    end

    assert_redirected_to security_publishers_path, "redirects to two_factor_registrations"
    refute @request.flash[:modal_partial]
  end

  test "TOTP registration creation after prompt" do
    sign_in publishers(:completed)

    ROTP::TOTP.any_instance.stubs(:verify_with_drift).returns(true)

    get prompt_security_publishers_path

    assert_difference("TotpRegistration.count") do
      post totp_registrations_path, params: {
        totp_password: "123456",
        totp_registration: { secret: ROTP::Base32.random_base32 }
      }
    end

    assert_redirected_to home_publishers_path, "redirects to dashboard"
    assert @request.flash[:modal_partial]

    follow_redirect!

    assert_select '#js-open-modal-on-load'
  end

  test "TOTP registration reconfiguration" do
    publisher = publishers(:completed)
    totp_registration = totp_registrations(:default)
    publisher.update_attribute(:totp_registration, totp_registration)

    sign_in publisher

    ROTP::TOTP.any_instance.stubs(:verify_with_drift).returns(true)

    assert_no_difference("TotpRegistration.count") do
      post totp_registrations_path, params: {
        totp_password: "123456",
        totp_registration: { secret: ROTP::Base32.random_base32 }
      }
    end

    assert_redirected_to security_publishers_path, "redirects to two_factor_registrations"
  end
end
