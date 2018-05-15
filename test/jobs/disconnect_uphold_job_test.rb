require "test_helper"
require "webmock/minitest"

class DisconnectUpholdJobTest < ActiveJob::TestCase
  test "requests that eyeshade disconnect a publisher's wallet" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:verified)
      publisher.uphold_verified = false
      publisher.save!

      stub_request(:put, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
        with(headers: {'Accept'=>'*/*',
                       'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization'=>"Bearer #{Rails.application.secrets[:api_eyeshade_key]}",
                       'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'},
             body:
               <<~BODY
                {
                  "provider": "uphold", 
                  "parameters": {}
                }
        BODY
        ).
        to_return(status: 200, headers: {})

      DisconnectUpholdJob.perform_now(publisher_id: publisher.id)

      publisher.reload
      refute publisher.uphold_verified?
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end
