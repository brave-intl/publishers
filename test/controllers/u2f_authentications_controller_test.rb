# typed: false

require "test_helper"

class U2fAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def canned_u2f_response(registration)
    ActiveSupport::JSON.encode({
      keyHandle: registration.key_handle,
      clientData: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiMEVxTHk3TExoYWQyVVN1Wk9ScWRqZThsdG9VWHZQVUU5aHQyRU5sZ2N5VSIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0OjMwMDAiLCJjaWRfcHVia2V5IjoidW51c2VkIn0",
      signatureData: "AQAAAAowRQIgfFLvGl1joGFlmZKPgIkimfJGt5glVEdiUYDtF8olMJgCIQCHIMR9ofM7VE7U6xURkDce8boCHwLq-vyVB9rWcKcscQ"
    })
  end

  test "U2F Authentication creation when pending_2fa_current_publisher_id" do
    publisher = publishers(:completed)
    registration = u2f_registrations(:default)
    publisher.u2f_registrations << registration

    visit_authentication_url publisher
    assert_redirected_to controller: "two_factor_authentications"

    TwoFactorAuth::WebauthnVerifyService.any_instance.stubs(:call).returns(success_struct_empty)

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response(registration)
    }

    assert_redirected_to controller: "/publishers", action: "home"
  end

  test "U2F Authentication creation fails when pending_2fa_current_publisher_id" do
    publisher = publishers(:completed)
    registration = u2f_registrations(:default)
    publisher.u2f_registrations << registration

    visit_authentication_url publisher
    assert_redirected_to controller: "two_factor_authentications"

    TwoFactorAuth::WebauthnVerifyService.any_instance.stubs(:call).returns(error_struct)

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response(registration)
    }

    assert_redirected_to controller: "two_factor_authentications"
  end
end
