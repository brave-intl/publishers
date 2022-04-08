require "test_helper"

class OAuth2ClientCredentialsTest < ActiveSupport::TestCase
  include Oauth2::Structs
  include MockOauth2Responses
  extend T::Sig

  let(:klass) { Oauth2::ClientCredentials }
  let(:client_id) { "any value" }
  let(:client_secret) { "any secret value" }
  let(:token_url) { "https://example.com/oauth2/token" }
  let(:payload) { {client_id: client_id, client_secret: client_secret, token_url: token_url} }
  let(:refresh_token) { "any stubbed token value" }
  let(:refresh_token_response) { {access_token: "access_token", expires_in: 10.minutes.to_i, refresh_token: "refresh_token", token_type: "example"} }
  let(:error_response) { {error: "invalid_grant", error_description: "Ann error occurred"} }

  test "#new" do
    assert_instance_of(klass, klass.new(**payload))
  end

  describe "#refresh_token" do
    describe "when unknown unsuccessful" do
      let(:response) { Net::HTTPInternalServerError }

      before do
        mock_unknown_failure(token_url)
      end

      test "it should raise exception" do
        assert_raises(Oauth2::ClientCredentials::UnknownError) { klass.new(**payload).refresh_token(refresh_token) }
      end
    end

    describe "when known unsuccessful" do
      let(:response) { ErrorResponse }

      before do
        mock_token_failure(token_url)
      end

      test "it should return an ErrorResponse" do
        assert_instance_of(response, klass.new(**payload).refresh_token(refresh_token))
      end
    end

    describe "when successful" do
      let(:response) { RefreshTokenResponse }

      before do
        mock_refresh_token_success(token_url)
      end

      test "it should return a RefreshTokenResponse" do
        assert_instance_of(response, klass.new(**payload).refresh_token(refresh_token))
      end
    end
  end
end
