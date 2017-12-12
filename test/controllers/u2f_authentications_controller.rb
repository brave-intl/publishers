require 'test_helper'

def canned_u2f_response(registration)
  return ActiveSupport::JSON.encode({
    keyHandle: registration.key_handle,
    clientData: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiMEVxTHk3TExoYWQyVVN1Wk9ScWRqZThsdG9VWHZQVUU5aHQyRU5sZ2N5VSIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0OjMwMDAiLCJjaWRfcHVia2V5IjoidW51c2VkIn0",
    signatureData: "AQAAAAowRQIgfFLvGl1joGFlmZKPgIkimfJGt5glVEdiUYDtF8olMJgCIQCHIMR9ofM7VE7U6xURkDce8boCHwLq-vyVB9rWcKcscQ"
  })
end

class U2fAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "U2F Authentications page requires pending_2fa_current_publisher_id" do
    get(new_u2f_authentication_path)
    assert_redirected_to(root_path)
  end

  test "U2F Authentications page renders when pending_2fa_current_publisher_id" do
    publisher = publishers(:completed)
    publisher.u2f_registrations << u2f_registrations(:default)

    visit_authentication_url publisher
    assert_redirected_to new_u2f_authentication_url

    follow_redirect!
    assert_match("Welcome to 2fa authentication", response.body)
    assert_select("input[name=u2f_app_id][value=?]", @controller.u2f.app_id)
    assert_select("input[name=u2f_challenge][value]")
    # This field has a JSON array values
    assert_select("input[name=u2f_sign_requests][value^='[']")
    # Check that response field is provided but not assigned a value
    assert_select("input[name=u2f_response]:not([value])")
    assert_select("button[type=submit]")
  end

  test "U2F Authentication creation when pending_2fa_current_publisher_id" do
    publisher = publishers(:completed)
    registration = u2f_registrations(:default)
    publisher.u2f_registrations << registration

    visit_authentication_url publisher
    assert_redirected_to new_u2f_authentication_url, "preconf - visiting authentication url redirects to 2fa page"

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
    assert_redirected_to new_u2f_authentication_url, "preconf - visiting authentication url redirects to 2fa page"

    U2fAuthenticationsController.any_instance.stubs(:u2f).raises(U2F::Error.new)

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response(registration)
    }

    assert_redirected_to new_u2f_authentication_path, "after 2fa post failure user can try again"
  end
end
