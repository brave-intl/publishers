require "test_helper"

class RegisterPublisherWithSendGridJobTest < ActiveJob::TestCase
  before do
    VCR.insert_cassette name
  end

  after do
    VCR.eject_cassette
  end

  test "verify RegisterPublisherWithSendGridJob successfully completes" do
    Rails.application.secrets[:sendgrid_api_offline] = false

    begin
      publisher = publishers(:completed)

      perform_enqueued_jobs do
        assert RegisterPublisherWithSendGridJob.perform_later(publisher.id)
      end
    ensure
      Rails.application.secrets[:sendgrid_api_offline] = true
    end
  end
end
