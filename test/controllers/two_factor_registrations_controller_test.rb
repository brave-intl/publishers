require "test_helper"

class TwoFactorRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "index renders registered TOTP secret" do
    publisher = publishers(:completed)
    totp_registration = totp_registrations(:default)
    publisher.update_attribute(:totp_registration, totp_registration)

    sign_in publisher
    get security_publishers_path

    assert_response :success
    assert_match "Enabled", response.body
    assert_match "Authenticator app has been set up", response.body
    assert_select "a[href=?]:contains(Reconfigure)", new_totp_registration_path
  end

  test "index renders a registered U2F key" do
    publisher = publishers(:completed)
    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    sign_in publisher
    get security_publishers_path

    assert_response :success
    assert_match u2f_registration.name, response.body
    assert_match /Set up an authenticator as\sthe secondary 2FA/, response.body
    assert_select "a[data-method=delete][href=?]", u2f_registration_path(u2f_registration)
  end

  test "index renders many registered U2F keys" do
    publisher = publishers(:completed)

    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    additional_u2f_registration = u2f_registrations(:additional)
    publisher.u2f_registrations << additional_u2f_registration

    sign_in publisher
    get security_publishers_path

    assert_response :success
    assert_match u2f_registration.name, response.body
    assert_match additional_u2f_registration.name, response.body
    assert_match "Authenticator app has not been set up", response.body
    assert_select "a[data-method=delete][href=?]", u2f_registration_path(u2f_registration)
    assert_select "a[data-method=delete][href=?]", u2f_registration_path(additional_u2f_registration)
  end

  test "prompt renders links" do
    publisher = publishers(:completed)

    sign_in publisher
    get prompt_security_publishers_path

    assert_response :success
    assert_select "a[href=?]", home_publishers_path
    assert_select "a[href=?]", security_publishers_path

    assert @request.session[:prompted_for_two_factor_registration_at_signup]
  end
end
