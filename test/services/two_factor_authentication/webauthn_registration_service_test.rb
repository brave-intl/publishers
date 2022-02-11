# typed: false
# frozen_string_literal: true

require "test_helper"

class WebauthnRegistrationServiceTest < ActiveSupport::TestCase
  test "success creates a new registration" do
    publisher = publishers(:completed)
    mock_credential = mock
    mock_credential.expects(:verify).with(5).returns(true)
    mock_credential.expects(:id).returns(1)
    mock_credential.expects(:public_key).returns(1)
    mock_credential.expects(:sign_count).returns(1)

    mock_credentialer = mock
    mock_credentialer.expects(:from_create).returns(mock_credential)

    registrar = TwoFactorAuth::WebauthnRegistrationService.new(webauthn_credentialer: mock_credentialer)

    assert_difference("U2fRegistration.count") do
      result = registrar.call(publisher: publisher,
        webauthn_response: JSON.dump(""),
        name: "name",
        challenge: 5)

      assert result.result
    end
  end

  test "failure creates no new registration" do
    publisher = publishers(:completed)
    mock_credential = mock
    mock_credential.expects(:verify).raises(WebAuthn::Error.new)

    mock_credentialer = mock
    mock_credentialer.expects(:from_create).returns(mock_credential)

    registrar = TwoFactorAuth::WebauthnRegistrationService.new(webauthn_credentialer: mock_credentialer)

    refute_difference("U2fRegistration.count") do
      result = registrar.call(publisher: publisher,
        webauthn_response: JSON.dump(""),
        name: "name",
        challenge: 5)

      assert result.errors
    end
  end
end
