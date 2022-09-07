# typed: false

require "test_helper"

class WebauthnConfigurationTest < ActiveSupport::TestCase
  test "Webauthn supported verification algorithms are correctly configured" do
    assert WebAuthn.configuration.algorithms.include?("ES256")
    assert WebAuthn.configuration.algorithms.include?("ES384")
    assert WebAuthn.configuration.algorithms.include?("ES512")
    assert WebAuthn.configuration.algorithms.include?("PS256")
    assert WebAuthn.configuration.algorithms.include?("PS384")
    assert WebAuthn.configuration.algorithms.include?("PS512")
    assert !WebAuthn.configuration.algorithms.include?("RS256")
  end
end
