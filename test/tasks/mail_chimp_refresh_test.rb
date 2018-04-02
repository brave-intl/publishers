require 'test_helper'

class MailChimpRefreshTest < ActiveJob::TestCase

  test "upserts all email verified publishers to MailChimp with one RegisterPublisherWithMailChimpJob per publisher" do
    assert_enqueued_with job: RegisterPublisherWithMailChimpJob do
      Rake::Task["mailchimp:refresh"].invoke
    end

    assert_enqueued_jobs Publisher.email_verified.count
  end
end