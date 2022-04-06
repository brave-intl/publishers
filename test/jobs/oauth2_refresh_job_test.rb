require 'test_helper'

class Oauth2RefreshJobTest < ActiveJob::TestCase
  include MockOauth2Responses
  let(:connection) { uphold_connections(:google_connection) }

  describe "when record !found" do
    test "it should raise an exception" do
      assert_instance_of(ActiveRecord::RecordNotFound, Oauth2RefreshJob.perform_now("fake identifier", UpholdConnection))
    end
  end

  describe "when record found" do
    describe "when successful" do
      before do
        mock_refresh_token_success(connection.token_url)
      end

      test "deletes a publisher and his or her channels" do
        assert_instance_of(UpholdConnection, Oauth2RefreshJob.perform_now(connection.id, UpholdConnection).connection)
      end
    end

    describe "when unsuccessful" do
      before do
        mock_token_failure(connection.token_url)
      end

      test "deletes a publisher and his or her channels" do
        assert_instance_of(BFailure, Oauth2RefreshJob.perform_now(connection.id, UpholdConnection))
      end
    end
  end
end
