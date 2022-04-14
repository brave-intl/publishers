require "test_helper"

class Oauth2RefreshJobTest < ActiveJob::TestCase
  include MockOauth2Responses
  let(:connection) { uphold_connections(:google_connection) }
  let(:klass) { UpholdConnection.name }

  describe "when record !found" do
    test "it should raise an exception" do
      assert_instance_of(ActiveRecord::RecordNotFound, Oauth2RefreshJob.perform_now("fake identifier", klass))
    end
  end

  describe "when record found" do
    describe "when successful" do
      before do
        mock_refresh_token_success(UpholdConnection.oauth2_client.token_url)
      end

      test "refreshes the token" do
        assert_instance_of(UpholdConnection, Oauth2RefreshJob.perform_now(connection.id, klass))
      end
    end

    describe "when unsuccessful" do
      before do
        mock_token_failure(UpholdConnection.oauth2_client.token_url)
      end

      test "returns an erro" do
        assert_instance_of(Oauth2::Responses::ErrorResponse, Oauth2RefreshJob.perform_now(connection.id, klass))
      end
    end
  end
end
