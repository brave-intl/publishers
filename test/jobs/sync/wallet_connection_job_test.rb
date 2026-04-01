require "test_helper"

class Oauth2BatchRefreshJobTest < ActiveJob::TestCase
  include MockOauth2Responses
  include MockRewardsResponses

  describe "#perform" do
    before do
      stub_rewards_parameters
    end

    describe "BitflyerConnection" do
      let(:conn) { bitflyer_connections(:enabled_bitflyer_connection) }

      describe "when success" do
        before do
          mock_refresh_token_success(conn.class.oauth2_client.token_url)
        end

        it "should return self" do
          assert_instance_of(conn.class, Sync::WalletConnectionJob.perform_now(conn, conn.class.name))
        end
      end

      describe "when failure" do
        before do
          mock_token_failure(conn.class.oauth2_client.token_url)
        end

        it "should return self" do
          assert_instance_of(Oauth2::Responses::ErrorResponse, Sync::WalletConnectionJob.perform_now(conn, conn.class.name))
        end
      end
    end
  end
end
