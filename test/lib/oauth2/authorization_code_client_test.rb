require "test_helper"

class OAuth2AuthorizationCodeTest < ActiveSupport::TestCase
  include Oauth2::Responses
  include MockOauth2Responses

  let(:klass) { Oauth2::AuthorizationCodeClient }
  let(:client_id) { "any value" }
  let(:client_secret) { "any secret value" }
  let(:authorization_url) { "https://example.com/oauth2/authorize" }
  let(:config) { Oauth2::Config::Uphold }
  let(:token_url) { config.token_url }
  let(:refresh_token) { "any stubbed token value" }
  let(:refresh_token_response) { {access_token: "access_token", expires_in: 10.minutes.to_i, refresh_token: "refresh_token", token_type: "example"} }
  let(:error_response) { {error: "invalid_grant", error_description: "Ann error occurred"} }

  test "#new" do
    assert_instance_of(klass, klass.new(config))
  end

  describe "#refresh_token" do
    describe "when success not-to-spec partially known" do
      before do
        mock_refresh_token_success(token_url, to_spec: false)
      end

      test "it should return error responsep" do
        assert_instance_of(Oauth2::Responses::RefreshTokenResponse, klass.new(config).refresh_token(refresh_token))
      end
    end

    describe "when failure not-to-spec partially known" do
      before do
        mock_token_failure(token_url, to_spec: false)
      end

      test "it should return error responsep" do
        assert_instance_of(Oauth2::Responses::ErrorResponse, klass.new(config).refresh_token(refresh_token))
      end
    end

    describe "when not-to-spec unknown with 400 status" do
      before do
        stub_request(:post, token_url)
          .to_return(status: 400, body: {is_not: "a", valid_oauth: "response object"}.to_json)
      end

      test "it should raise exception" do
        assert_instance_of(Oauth2::Errors::UnknownError, klass.new(config).refresh_token(refresh_token))
      end
    end

    describe "when application/json" do
      let(:config) { Oauth2::Config::Gemini }

      describe "when unknown unsuccessful" do
        let(:response) { Net::HTTPInternalServerError }

        before do
          mock_unknown_failure(token_url)
        end

        test "it should raise exception" do
          assert_instance_of(Oauth2::Errors::UnknownError, klass.new(config).refresh_token(refresh_token))
        end
      end

      describe "when known unsuccessful" do
        let(:response) { Oauth2::Responses::ErrorResponse }

        before do
          mock_token_failure(token_url)
        end

        test "it should return an ErrorResponse" do
          assert_instance_of(response, klass.new(config).refresh_token(refresh_token))
        end
      end

      describe "when successful" do
        let(:response) { Oauth2::Responses::RefreshTokenResponse }

        before do
          mock_refresh_token_success(token_url)
        end

        test "it should return a RefreshTokenResponse" do
          assert_instance_of(response, klass.new(config).refresh_token(refresh_token))
        end
      end
    end
  end

  describe "when application/x-www-form-urlencoded" do
    describe "when unknown unsuccessful" do
      let(:response) { Net::HTTPInternalServerError }

      before do
        mock_unknown_failure(token_url)
      end

      test "it should raise exception" do
        assert_instance_of(Oauth2::Errors::UnknownError, klass.new(config).refresh_token(refresh_token))
      end
    end

    describe "when known unsuccessful" do
      let(:response) { Oauth2::Responses::ErrorResponse }

      before do
        mock_token_failure(token_url)
      end

      test "it should return an ErrorResponse" do
        assert_instance_of(response, klass.new(config).refresh_token(refresh_token))
      end
    end

    describe "when successful" do
      let(:response) { Oauth2::Responses::RefreshTokenResponse }

      before do
        mock_refresh_token_success(token_url)
      end

      test "it should return a RefreshTokenResponse" do
        assert_instance_of(response, klass.new(config).refresh_token(refresh_token))
      end
    end
  end
end
