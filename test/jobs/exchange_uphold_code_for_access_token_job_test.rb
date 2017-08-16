require 'test_helper'
require 'webmock/minitest'

class ExchangeUpholdCodeForAccessTokenJobTest < ActiveJob::TestCase
  test "sets uphold_access_parameters on success" do
    publisher = publishers(:verified)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    publisher.save!

    stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
        .with(body: "code=#{publisher.uphold_code}&grant_type=authorization_code")
        .to_return(status: 201, body: "{\"access_token\":\"FAKEACCESSTOKEN\",\"token_type\":\"bearer\",\"refresh_token\":\"FAKEREFRESHTOKEN\",\"scope\":\"cards:write\"}")

    ExchangeUpholdCodeForAccessTokenJob.perform_now(publisher_id: publisher.id)
    publisher.reload

    assert_nil publisher.uphold_code
    refute_nil publisher.uphold_access_parameters
  end

  test "clears uphold_code on invalid_grant" do
    publisher = publishers(:verified)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    publisher.save!

    stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
        .with(body: "code=#{publisher.uphold_code}&grant_type=authorization_code")
        .to_return(status: 400, body: '{"error":"invalid_grant"}')

    ExchangeUpholdCodeForAccessTokenJob.perform_now(publisher_id: publisher.id)
    publisher.reload

    assert_nil publisher.uphold_code
    assert_nil publisher.uphold_access_parameters
  end

  test "preserves uphold_code on other errors" do
    publisher = publishers(:verified)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    publisher.save!

    stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
        .with(body: "code=#{publisher.uphold_code}&grant_type=authorization_code")
        .to_return(status: 400, body: '{"error":"something_else"}')

    ExchangeUpholdCodeForAccessTokenJob.perform_now(publisher_id: publisher.id)
    publisher.reload

    refute_nil publisher.uphold_code
    assert_nil publisher.uphold_access_parameters
  end
end
