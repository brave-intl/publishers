require 'test_helper'

class SendGridRefreshTest < ActiveJob::TestCase
  before do
    VCR.insert_cassette name
  end

  after do
    VCR.eject_cassette
  end

  test "upserts all email verified publishers to SendGrid with paginated requests" do
    # Remove all but a subset of publishers so new fixtures do not break the test
    Publisher.where.not(email: "alice@default.org").
        where.not(email: "alice@verified.org").
        where.not(email: "alice_totp@verified.org").
        where.not(email: "alice@completed.org").
        where.not(email: "alice@spud.com").
        where.not(email: "hello@brave.com").
        where.not(email: "only@notes.org").
        where.not(email: "alice2@verified.org").
        where.not(email: "fred@vglobal.org").
        where.not(email: "fred@small.org").destroy_all

    assert_output(/Done. Refreshed #{Publisher.email_verified.not_admin.count} publishers to SendGrid./) do
      Rake::Task["sendgrid:refresh"].invoke(5)
    end
  end
end
