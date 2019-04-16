require "test_helper"
require "webmock/minitest"

class UploadUpholdAccessParametersJobTest < ActiveJob::TestCase
  test "clears uphold_access_parameters on success" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.uphold_connection.uphold_access_parameters = '{"access_token":"abc123","token_type":"bearer"}'
      publisher.save!

      stub_request(:put, /v1\/owners\/#{publisher.owner_identifier}\/wallet/).
        with(headers: {'Accept'=>'*/*',
                       'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization'=>"Bearer #{Rails.application.secrets[:api_eyeshade_key]}",
                       'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'},
             body:
               <<~BODY
                {
                  "provider": "uphold",
                  "parameters": {"access_token":"abc123","token_type":"bearer","server":"#{Rails.application.secrets[:uphold_api_uri]}"}
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
