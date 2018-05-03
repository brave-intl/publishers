require 'test_helper'

class SendGridRefreshTest < ActiveJob::TestCase
  before do
    VCR.insert_cassette name
  end

  after do
    VCR.eject_cassette
  end

  test "upserts all email verified publishers to SendGrid with paginated requests" do
    assert_output(/....\nDone. Refreshed #{Publisher.email_verified.count} publishers to SendGrid./) do
      Rake::Task["sendgrid:refresh"].invoke(5)
    end
  end
end