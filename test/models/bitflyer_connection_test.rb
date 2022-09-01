# typed: false

require "test_helper"
require "webmock/minitest"
require "jobs/sidekiq_test_case"

class BitflyerConnectionTest < SidekiqTestCase
  include MockOauth2Responses

  describe "Oauth2::AuthorizationCodeBase" do
    let(:klass) { BitflyerConnection }
    let(:conn) { bitflyer_connections(:enabled_bitflyer_connection) }

    describe "conn.class.oauth2_client" do
      it "should be truthy" do
        assert conn.class.oauth2_client
      end
    end

    # Today bitflyer only refreshes token on sync (so far as I can tell)
    describe "#sync_connection!!" do
      describe "when successful" do
        before do
          mock_refresh_token_success(klass.oauth2_client.token_url)
        end

        test "it should return expected outout" do
          inst = conn.refresh_authorization!
          assert_instance_of(klass, inst)
          inst.reload
          assert !conn.oauth_refresh_failed
        end
      end

      describe "when unsuccessful" do
        before do
          mock_token_failure(klass.oauth2_client.token_url)
        end

        test "it should return expected outout" do
          conn.refresh_authorization!
          conn.reload
          assert conn.oauth_refresh_failed
        end
      end
    end

    describe "#refresh_authorization!" do
      describe "when 403" do
        before do
          mock_unknown_failure(klass.oauth2_client.token_url, status: 403)
        end

        test "it should return expected outout" do
          inst = conn.refresh_authorization!
          assert_instance_of(Oauth2::Responses::ErrorResponse, inst)
          conn.reload
          assert conn.oauth_refresh_failed
        end
      end

      describe "when successful" do
        before do
          mock_refresh_token_success(klass.oauth2_client.token_url)
        end

        test "it should return expected outout" do
          inst = conn.refresh_authorization!
          assert_instance_of(klass, inst)
          inst.reload
          assert !conn.oauth_refresh_failed
        end
      end

      describe "when unsuccessful" do
        before do
          mock_token_failure(klass.oauth2_client.token_url)
        end

        test "it should return expected outout" do
          conn.refresh_authorization!
          conn.reload
          assert conn.oauth_refresh_failed
        end
      end
    end
  end
end
