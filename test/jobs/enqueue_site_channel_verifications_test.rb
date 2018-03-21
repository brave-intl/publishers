require "test_helper"

class EnqueueSiteChannelVerificationsTest < ActiveJob::TestCase
  test "#perform enqueue verifications" do
    channel = channels(:global_inprocess3)
    assert_enqueued_with(job: VerifySiteChannel, args: [{ channel_id: channel.id }]) do
      EnqueueSiteChannelVerifications.perform_now
    end
  end
end
