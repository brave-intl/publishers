require "test_helper"

class BitflyerRefreshJobTest < ActiveJob::TestCase
  include MockOauth2Responses
  let(:limit) { 5 }

  describe "#perform" do
    before do
      mock_refresh_token_success(BitflyerConnection.oauth2_config.token_url)
      BitflyerConnection.update_all(oauth_refresh_failed: false, access_expiration_time: 2.days.ago)
    end

    describe "with args" do
      let(:result) { BitflyerRefreshJob.perform_now(wait: 0.01, limit: limit, async: false) }

      before do
        result
      end

      it "should return count" do
        assert_equal(3, result)
      end

      it "should return limit" do
        assert_equal(2, BitflyerConnection.where(oauth_refresh_failed: true).count)
      end
    end
  end
end
