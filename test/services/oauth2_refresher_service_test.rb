require "test_helper"

class Oauth2RefresherServiceTest < ActiveSupport::TestCase
  include MockOauth2Responses
  let(:klass) { Oauth2RefresherService }
  let(:connection) { uphold_connections(:google_connection) }

  test "#build" do
    assert_instance_of(klass, klass.build)
  end

  describe "#call" do
    describe "when successful" do
      before do
        mock_refresh_token_success(connection.token_url)
      end

      test "it should return expected outout" do
        assert_instance_of(UpholdConnection, klass.build.call(connection).connection)
      end
    end
  end
end
