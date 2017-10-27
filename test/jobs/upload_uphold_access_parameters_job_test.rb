require "test_helper"
require "webmock/minitest"

class UploadUpholdAccessParametersJobTest < ActiveJob::TestCase
  test "clears uphold_access_parameters on success" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.uphold_access_parameters = '{"access_token":"abc123","token_type":"bearer"}'
      publisher.save!

      stub_request(:put, /v2\/publishers\/#{publisher.brave_publisher_id}\/wallet/)
          .with(body:
            <<~BODY
              {
                "provider": "uphold", 
                "parameters": {"access_token":"abc123","token_type":"bearer","server":"#{Rails.application.secrets[:uphold_api_uri]}"}, 
                "verificationId": "#{publisher.id}"
              }
            BODY
          )

      UploadUpholdAccessParametersJob.perform_now(publisher_id: publisher.id)

      publisher.reload
      assert publisher.uphold_verified?
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end
