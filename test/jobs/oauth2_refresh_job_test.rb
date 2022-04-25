require "test_helper"

class Oauth2RefreshJobTest < ActiveJob::TestCase
  include MockOauth2Responses
  include ActionMailer::TestHelper

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
        assert ActionMailer::Base.deliveries.count == 0
        assert !connection.oauth_failure_email_sent
      end

      test "returns an error when !notify" do
        assert_instance_of(Oauth2::Responses::ErrorResponse, Oauth2RefreshJob.perform_now(connection.id, klass))
        assert ActionMailer::Base.deliveries.count == 0
      end

      test "returns an error when notify" do
        result = Oauth2RefreshJob.perform_now(connection.id, klass, notify: true)
        assert_instance_of(Oauth2::Responses::ErrorResponse, result)
        assert ActionMailer::Base.deliveries.count == 1
        connection.reload
        assert connection.oauth_failure_email_sent
      end
    end
  end
end
