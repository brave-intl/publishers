# typed: false

require "test_helper"

class PublisherStatusUpdaterTest < ActiveJob::TestCase
  describe "PublisherStatusUpdater" do
    test "updates status" do
      channel = channels(:default)
      publisher = channel.publisher
      assert !publisher.suspended?
      admin = publishers(:admin)
      status_update = PublisherStatusUpdater.new.perform(
        user: channel.publisher,
        admin: admin,
        status: "suspended",
        note: "looked fishy"
      )

      assert status_update["status"] == "suspended"
      assert publisher.suspended?
    end

    test "does not suspend a whitelisted publisher" do
      channel = channels(:default)
      admin = publishers(:admin)
      publisher = channel.publisher
      PublisherWhitelistUpdate.create!(publisher: publisher, enabled: true, publisher_note: PublisherNote.create!(publisher: publisher, note: "test", created_by: admin))
      assert !publisher.suspended?
      admin = publishers(:admin)
      assert_raises PublisherStatusUpdater::CannotSuspendWhitelisted do
        PublisherStatusUpdater.new.perform(
          user: channel.publisher,
          admin: admin,
          status: "suspended",
          note: "looked fishy"
        )
      end
    end
  end
end
