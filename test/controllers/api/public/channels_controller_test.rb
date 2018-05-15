require "test_helper"
require "shared/mailer_test_helper"

class Api::Public::ChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'a site not in the system' do
    get "/api/public/channels/identity?publisher=brave.com"
    assert_equal 404, response.status
  end

  test 'a site not yet verified' do
    channel = channels(:small_media_group_to_verify)
    get "/api/public/channels/identity?publisher=#{channel.details.brave_publisher_id}"
    response_body = JSON.parse(response.body)
    assert_equal 200, response.status
    assert_equal channel.details.brave_publisher_id, response_body["SLD"]
    assert_equal ""         , response_body["RLD"]
    assert_equal ""         , response_body["QLD"]
    assert_equal channel.details.brave_publisher_id, response_body["URL"]
    assert_nil   response_body['properties']
  end

  test 'a site that is verified' do
    channel = channels(:verified)
    get "/api/public/channels/identity?publisher=#{channel.details.brave_publisher_id}"
    response_body = JSON.parse(response.body)

    assert_equal channel.details.brave_publisher_id , response_body["SLD"]
    assert_equal ""                                 , response_body["RLD"]
    assert_equal ""                                 , response_body["QLD"]
    assert_equal true                               , response_body['properties']['verified']
  end

  test 'a youtube channel' do
    channel = channels(:youtube_new)
    get "/api/public/channels/identity?publisher=youtube%23channel%3A#{channel.details.youtube_channel_id}"
    response_body = JSON.parse(response.body)

    assert_equal 200                                , response.status
    assert_equal 'provider'                         , response_body['publisherType']
    assert_equal 'youtube'                          , response_body['providerName']
    assert_equal 'channel'                          , response_body['providerSuffix']
    assert_equal channel.details.youtube_channel_id , response_body['providerValue']
    assert_match /youtube.com\/channel\/#{channel.details.youtube_channel_id}/, response_body["URL"]
    assert_equal "youtube#channel"                  , response_body["TLD"]
    assert_equal "youtube#channel:#{channel.details.youtube_channel_id}", response_body["SLD"]
    assert_equal channel.details.youtube_channel_id , response_body["RLD"]
    assert_equal ""                                 , response_body["QLD"]
    assert_equal true                               , response_body['properties']['verified']

    channel.update(verified: false)
    get "/api/public/channels/identity?publisher=youtube%23channel%3A#{channel.details.youtube_channel_id}"
    response_body = JSON.parse(response.body)

    assert_equal 200                                , response.status
    assert_equal 'provider'                         , response_body['publisherType']
    assert_equal 'youtube'                          , response_body['providerName']
    assert_equal 'channel'                          , response_body['providerSuffix']
    assert_equal channel.details.youtube_channel_id , response_body['providerValue']
    assert_match /youtube.com\/channel\/#{channel.details.youtube_channel_id}/, response_body["URL"]
    assert_equal "youtube#channel"                  , response_body["TLD"]
    assert_equal "youtube#channel:#{channel.details.youtube_channel_id}", response_body["SLD"]
    assert_equal channel.details.youtube_channel_id , response_body["RLD"]
    assert_equal ""                                 , response_body["QLD"]
    assert_nil   response_body['properties']
  end
end
