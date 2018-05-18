require "test_helper"

class RegisterPublisherWithSendGridJobTest < ActiveJob::TestCase
  before do
    VCR.insert_cassette name
  end

  after do
    VCR.eject_cassette
  end

  test "verify RegisterPublisherWithSendGridJob throttles successfully when flooded with requests" do
    Rails.application.secrets[:sendgrid_api_offline] = false

    begin
      publisher = publishers(:completed)

      start_time = Time.now.to_f

      perform_enqueued_jobs do
        assert RegisterPublisherWithSendGridJob.perform_later(publisher.id)
        assert RegisterPublisherWithSendGridJob.perform_later(publisher.id)
        assert RegisterPublisherWithSendGridJob.perform_later(publisher.id)
        assert RegisterPublisherWithSendGridJob.perform_later(publisher.id)
        assert RegisterPublisherWithSendGridJob.perform_later(publisher.id)
        assert RegisterPublisherWithSendGridJob.perform_later(publisher.id)
      end

      end_time = Time.now.to_f
      assert end_time >= start_time + 5
    ensure
      Rails.application.secrets[:sendgrid_api_offline] = true
    end
  end
end
