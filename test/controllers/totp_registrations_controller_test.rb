# typed: false

require "test_helper"

class TotpRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

  test "new requires authentication" do
    get new_totp_registration_path
    assert_redirected_to root_path, locale: "en"
  end

  test "new renders when authenticated with new key form" do
    sign_in publishers(:completed)
    get new_totp_registration_path

    assert_response :success
    assert_select "form[method=post][action=?]", totp_registrations_path(locale: :en) do
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
    assert_select "form[method=post][action=?]", totp_registrations_path(locale: :en) do
      assert_select "input[name=totp_password]:not([value])"
      assert_select "input[type=submit]"
    end
    assert_match "Reconfiguring will invalidate your existing authentication code devices", response.body
  end

  test "TOTP registration creation" do
    sign_in publishers(:completed)

    ROTP::TOTP.any_instance.stubs(:verify).returns(true)

    assert_difference("TotpRegistration.count") do
      post totp_registrations_path, params: {
        totp_password: "123456",
        totp_registration: {secret: ROTP::Base32.random_base32}
      }
    end

    assert_redirected_to controller: "/publishers/security"
    refute @request.flash[:modal_partial]
  end

  test "TOTP registration creation after prompt" do
    sign_in publishers(:completed)

    ROTP::TOTP.any_instance.stubs(:verify).returns(true)

    get prompt_security_publishers_path

    assert_difference("TotpRegistration.count") do
      post totp_registrations_path, params: {
        totp_password: "123456",
        totp_registration: {secret: ROTP::Base32.random_base32}
      }
    end

    assert_redirected_to controller: "/publishers", action: "home"
    assert @request.flash[:modal_partial]

    follow_redirect!

    assert_select "#js-open-modal-on-load"
  end

  test "TOTP registration reconfiguration" do
    publisher = publishers(:completed)
    totp_registration = totp_registrations(:default)
    publisher.update_attribute(:totp_registration, totp_registration)

    sign_in publisher

    ROTP::TOTP.any_instance.stubs(:verify).returns(Time.now.to_i)

    assert_no_difference("TotpRegistration.count") do
      post totp_registrations_path, params: {
        totp_password: "123456",
        totp_registration: {secret: ROTP::Base32.random_base32}
      }
    end

    assert_redirected_to controller: "two_factor_authentications"

    post totp_authentications_path, params: {
      totp_password: "123456"
    }

    assert_redirected_to controller: "/publishers/security"
  end

  test "logout everybody else on registration" do
    publisher = publishers(:completed)

    sign_in publisher
    another_session = open_session
    another_session.sign_in publisher

    ROTP::TOTP.any_instance.stubs(:verify).returns(true)

    assert_difference("TotpRegistration.count") do
      post totp_registrations_path, params: {
        totp_password: "123456",
        totp_registration: {secret: ROTP::Base32.random_base32}
      }
    end

    assert_redirected_to controller: "/publishers/security"
    refute @request.flash[:modal_partial]

    another_session.get "/publishers/security"
    another_session.assert_redirected_to root_path # logout redirects to root
  end
end
