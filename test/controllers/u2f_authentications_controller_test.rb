require "test_helper"

class U2fAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def canned_u2f_response(registration)
    return ActiveSupport::JSON.encode({
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
    assert_redirected_to two_factor_authentications_path, "precond - visiting authentication url redirects to 2fa page"

    U2fAuthenticationsController.any_instance.stubs(:u2f).returns(mock(:authenticate!))

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response(registration)
    }

    assert_redirected_to home_publishers_path, "after 2fa post user is directed to the home path"
  end

  test "U2F Authentication creation fails when pending_2fa_current_publisher_id" do
    publisher = publishers(:completed)
    registration = u2f_registrations(:default)
    publisher.u2f_registrations << registration

    visit_authentication_url publisher
    assert_redirected_to two_factor_authentications_path, "precond - visiting authentication url redirects to 2fa page"

    U2fAuthenticationsController.any_instance.stubs(:u2f).raises(U2F::Error.new)

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response(registration)
    }

    assert_redirected_to two_factor_authentications_path, "after 2fa post failure user can try again"
  end
end
