require "test_helper"

class UpholdRefreshJobTest < ActiveJob::TestCase
  include MockOauth2Responses

  describe "#perform" do
    let(:klass) { UpholdConnection }
    let(:described_class) { UpholdRefreshJob }

    before do
      mock_refresh_token_success(klass.oauth2_config.token_url)
      klass.update_all(oauth_refresh_failed: false, access_expiration_time: 2.days.ago)
    end

    describe "without limit" do
      let(:result) { described_class.perform_now(wait: 0, limit: nil, async: false) }

      before do
        result
      end

      it "should return all" do
        assert_equal(klass.count, result)
      end

      it "should fail invalid connections" do
        assert_equal(24, klass.where(oauth_refresh_failed: true).count)
      end
    end
  end
end
