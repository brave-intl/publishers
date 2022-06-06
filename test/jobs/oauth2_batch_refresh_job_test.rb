require "test_helper"

class Oauth2BatchRefreshJobTest < ActiveJob::TestCase
  let(:limit) { 5 }

  describe "#perform" do
    before do
      GeminiConnection.update(oauth_refresh_failed: false, access_expiration_time: 2.days.ago)
    end

    describe "without args" do
      test "it should return an integer" do
        result = Oauth2BatchRefreshJob.perform_now
        assert result > limit
      end
    end

    describe "witht args" do
      test "it should return limit" do
        result = Oauth2BatchRefreshJob.perform_now(wait: 0.01, limit: limit)
        # 10/23 UpholdConnection + 6/6 GeminiConnection + 3/3 Bitflyer Connection
        # based on existing fixtures.
        assert result == GeminiConnection.count - 1
      end
    end
  end
end
