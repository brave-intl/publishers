require "test_helper"

class EnqueueSiteChannelVerificationsTest < ActiveJob::TestCase
  test "#perform enqueue verifications" do
    publisher = publishers(:default)
    channel_details = site_channel_details(:default_details)
    assert_enqueued_with(job: VerifySiteChannel, args: [{ brave_publisher_id: channel_details.brave_publisher_id }]) do
      EnqueueSiteChannelVerifications.perform_now
    end
  end
end
