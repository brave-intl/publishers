require "test_helper"

class GeminiRefreshJobTest < ActiveJob::TestCase
  include MockOauth2Responses
  include MockRewardsResponses

  let(:limit) { 7 }

  describe "#perform" do
    before do
      stub_rewards_parameters
      mock_refresh_token_success(GeminiConnection.oauth2_config.token_url)
      GeminiConnection.update_all(oauth_refresh_failed: false, access_expiration_time: 2.days.ago)
    end

    describe "without args" do
      test "it should return an integer" do
        result = GeminiRefreshJob.perform_now
        assert result > limit
      end
    end

    describe "witht args" do
      test "it should return limit" do
        result = GeminiRefreshJob.perform_now(wait: 0.01, limit: limit)
        # 10/23 UpholdConnection + 6/6 GeminiConnection + 3/3 Bitflyer Connection
        # based on existing fixtures.
        assert result == GeminiConnection.count - 1
      end
    end
  end
end
