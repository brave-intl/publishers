# typed: false

require "test_helper"

class Batch::CustomAnnouncementJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends the custom announcement to the publisher" do
    publisher = publishers(:completed)

    assert_emails 1 do
      Batch::CustomAnnouncementJob.perform_now(publisher.id, "An update", "<p>Hello creators</p>")
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal [publisher.email], email.to
    assert_equal "An update", email.subject
    assert_includes email.html_part.body.to_s, "Hello creators</p>"
  end

  test "skips suspended publishers" do
    assert_no_emails do
      Batch::CustomAnnouncementJob.perform_now(publishers(:suspended).id, "An update", "<p>Hello</p>")
    end
  end

  test "skips publishers without an email" do
    publisher = publishers(:completed)
    publisher.update_column(:email, nil)

    assert_no_emails do
      Batch::CustomAnnouncementJob.perform_now(publisher.id, "An update", "<p>Hello</p>")
    end
  end
end
