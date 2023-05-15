# typed: false

require "test_helper"

class PublisherPayoutFeedbackStatusUpdaterTest < ActiveJob::TestCase
  describe "PublisherPayoutFeedbackStatusUpdater" do
    test "sets bad wallet status on bad wallets" do
      publisher = publishers(:uphold_connected)
      refute publisher.selected_wallet_provider.oauth_refresh_failed
      total_count_refresh_failed = UpholdConnection.payable_ignoring_oauth_failures.count

      mock_to_update_list = JSON.parse([
        {
          address: "123",
          owner: "publishers#uuid:#{publisher.id}",
          walletProvider: "uphold",
          walletProviderId: publisher.selected_wallet_provider.wallet_provider_id.to_s,
          publisher: "youtube#channel:dsf",
          note: "Account not permitted"
        }
      ].to_json)

      PublisherPayoutFeedbackStatusUpdater.build.call(to_update_list: mock_to_update_list)

      refute publisher.reload.selected_wallet_provider.oauth_refresh_failed
      assert publisher.reload.selected_wallet_provider.payout_failed
      assert_equal total_count_refresh_failed - 1, UpholdConnection.payable_ignoring_oauth_failures.count
    end
  end
end
