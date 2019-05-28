require "test_helper"

class PublisherStatusUpdateTest < ActiveSupport::TestCase
  test "must have a publisher" do
    status_update = PublisherStatusUpdate.new(status: "created")

    assert !status_update.valid?
  end

  test "must have a status" do
    publisher = publishers(:onboarding)
    status_update = PublisherStatusUpdate.new(publisher: publisher)

    assert !status_update.valid?
  end

  test "can select Publisher from PublisherStatusUpdate object and vice versa" do
    publisher = Publisher.new(name: "Carol", email: "carol@example.com")
    publisher.save!
    status_update = PublisherStatusUpdate.new(status: "created", publisher: publisher)
    status_update.save!

    publisher.reload
    assert_equal publisher, status_update.publisher
    assert_equal publisher.status_updates.first, status_update
  end

  test "assigning status not in PublisherStatusUpdate::ALL_STATUSES raises an error" do
    publisher = Publisher.new(name: "Carol", email: "carol@example.com")
    publisher.save!
    status_update = PublisherStatusUpdate.new(status: "invalid status", publisher: publisher)

    assert_raises do
      status_update.save!
    end
  end
end
