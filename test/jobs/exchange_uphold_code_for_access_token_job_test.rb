require 'test_helper'
require 'webmock/minitest'

class ExchangeUpholdCodeForAccessTokenJobTest < ActiveJob::TestCase
  test "sets uphold_access_parameters and schedules new UploadUpholdAccessParametersJob on success" do
    uphold_connection = publishers(:verified).uphold_connection
    uphold_connection.uphold_code = "foo"
    uphold_connection.uphold_access_parameters = nil
    uphold_connection.save!

    stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
      .with(body: "code=#{uphold_connection.uphold_code}&grant_type=authorization_code")
      .to_return(status: 201, body: "{\"access_token\":\"FAKEACCESSTOKEN\",\"token_type\":\"bearer\",\"refresh_token\":\"FAKEREFRESHTOKEN\",\"scope\":\"cards:write\"}")

  end

  test "clears uphold_code on invalid_grant" do
    publisher = publishers(:verified)
    publisher.uphold_connection.uphold_code = "foo"
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.uphold_connection.save!

    stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
      .with(body: "code=#{publisher.uphold_connection.uphold_code}&grant_type=authorization_code")
      .to_return(status: 400, body: '{"error":"invalid_grant"}')

    ExchangeUpholdCodeForAccessTokenJob.perform_now(uphold_connection_id: publisher.uphold_connection.id)
    publisher.reload
    publisher.uphold_connection.reload

    assert_nil publisher.uphold_connection.uphold_code
    assert_nil publisher.uphold_connection.uphold_access_parameters
  end

  test "preserves uphold_code on other errors" do
    publisher = publishers(:verified)
    publisher.uphold_connection.uphold_code = "foo"
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.uphold_connection.save!

    stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
      .with(body: "code=#{publisher.uphold_connection.uphold_code}&grant_type=authorization_code")
      .to_return(status: 400, body: '{"error":"something_else"}')

    ExchangeUpholdCodeForAccessTokenJob.perform_now(uphold_connection_id: publisher.uphold_connection.id)
    publisher.reload
    publisher.uphold_connection.reload

    refute_nil publisher.uphold_connection.uphold_code
    assert_nil publisher.uphold_connection.uphold_access_parameters
  end
end
