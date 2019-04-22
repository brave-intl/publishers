require 'test_helper'

class PublisherRemovalJobTest < ActiveJob::TestCase

  test "deletes a publisher and his or her channels" do
    publisher = publishers(:google_verified)
    assert_not_equal 0, publisher.channels.count
    PublisherRemovalJob.perform_now(publisher_id: publisher.id)
    publisher.reload
    assert_equal PublisherStatusUpdate::DELETED, publisher.email
    assert_equal PublisherStatusUpdate::DELETED, publisher.name
    assert_equal IPAddr.new(PublisherRemovalJob::DELETED_IP_ADDRESS), publisher.last_sign_in_ip
    assert_equal 0, publisher.channels.count
  end
end
