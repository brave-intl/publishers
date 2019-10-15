require 'test_helper'

class PublisherRemovalJobTest < ActiveJob::TestCase

  test "deletes a publisher and his or her channels" do
    publisher = publishers(:google_verified)
    publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE)
    assert_not_equal 0, publisher.channels.count
    PublisherRemovalJob.perform_now(publisher_id: publisher.id)
    publisher.reload
    assert_nil publisher.email
    assert_nil publisher.pending_email
    assert_equal PublisherStatusUpdate::DELETED, publisher.name
    assert_nil publisher.last_sign_in_ip
    assert_nil publisher.current_sign_in_ip
    publisher.channels.reload
    assert_equal 0, publisher.channels.count
    assert_equal 0, publisher.versions.count
  end

  test "deletes a publisher with a non-normal state and doesn't touch his or her channels" do
    publisher = publishers(:google_verified)
    publisher.status_updates.create(status: PublisherStatusUpdate::NO_GRANTS)
    assert_not_equal 0, publisher.channels.count
    PublisherRemovalJob.perform_now(publisher_id: publisher.id)
    publisher.reload
    assert_nil publisher.email
    assert_nil publisher.pending_email
    assert_equal PublisherStatusUpdate::DELETED, publisher.name
    assert_not_nil publisher.last_sign_in_ip
    assert_not_nil publisher.current_sign_in_ip
    assert_not_equal 0, publisher.channels.count
    assert_equal 0, publisher.versions.count
  end
end
