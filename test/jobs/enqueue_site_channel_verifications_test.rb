require "test_helper"

class EnqueueSiteChannelVerificationsTest < ActiveJob::TestCase
  test "#perform enqueue verifications" do
    channel = channels(:default)
    assert_enqueued_with(job: VerifySiteChannel, args: [{ channel_id: channel.id }]) do
      EnqueueSiteChannelVerifications.perform_now
    end
  end
end
