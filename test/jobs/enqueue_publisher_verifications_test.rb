require "test_helper"

class EnqueuePublisherVerificationsTest < ActiveJob::TestCase
  test "#perform enqueue verifications" do
    publisher = publishers(:default)
    # Hack to clean DB
    Publisher.where.not(id: publisher.id).delete_all
    assert_enqueued_with(job: VerifyPublisher, args: [{ brave_publisher_id: publisher.brave_publisher_id }]) do
      EnqueuePublisherVerifications.perform_now
    end
  end

  test "#perform doesn't enqueue verifications for old publishers" do
    publisher = publishers(:stale)
    # Hack to clean DB
    Publisher.where.not(id: publisher.id).delete_all
    assert_no_enqueued_jobs do
      EnqueuePublisherVerifications.perform_now
    end
  end
end
