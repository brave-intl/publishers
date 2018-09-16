require "test_helper"
# require "webmock/minitest"
# require 'vcr'
require "send_grid/api_helper"

class SendGridRegistrarTest < ActiveJob::TestCase
  before do
    VCR.insert_cassette name
  end

  after do
    VCR.eject_cassette
  end

  test "registers a new publisher with SendGrid and adds them to the Publisher List" do
    prev_sendgrid_api_offline = Rails.application.secrets[:sendgrid_api_offline]
    p "*********************************"
    p "Env: #{Rails.env}"
    p "Env: #{Rails.application.secrets[:sendgrid_api_key].first(5)}"
    p "*********************************"
    Rails.application.secrets[:sendgrid_api_offline] = false

    begin
      publisher = publishers(:completed)

      assert SendGridRegistrar.new(publisher: publisher).perform
    ensure
      Rails.application.secrets[:sendgrid_api_offline] = prev_sendgrid_api_offline
    end
  end

  test "registers a changed email and replaces emails in Publisher List" do
    prev_sendgrid_api_offline = Rails.application.secrets[:sendgrid_api_offline]
    Rails.application.secrets[:sendgrid_api_offline] = false

    begin
      publisher = publishers(:completed)
      prior_email = publisher.email

      publisher.email = "test@test.com"

      assert SendGridRegistrar.new(publisher: publisher, prior_email: prior_email).perform
    ensure
      Rails.application.secrets[:sendgrid_api_offline] = prev_sendgrid_api_offline
    end
  end
end
