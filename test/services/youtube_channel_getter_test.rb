require "test_helper"
require "webmock/minitest"

class YoutubeChannelGetterTest < ActiveJob::TestCase
  test "returns data for a single YouTube channel when channels are requested" do
    token = 'token123'
    publisher = publishers(:google_verified)
    channel_data = { 'id' => 'yt123' }

    stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization' => "Bearer #{token}",
                       'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

    assert_equal channel_data, YoutubeChannelGetter.new(publisher: publisher, token: token).perform
  end

  test "returns nil when channels are requested for a YouTube user has no channels" do
    token = 'token123'
    publisher = publishers(:google_verified)

    stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'Authorization' => "Bearer #{token}",
                     'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: {}.to_json, headers: {})

    assert_nil YoutubeChannelGetter.new(publisher: publisher, token: token).perform
  end

  test "returns data for a single YouTube channel when a particular channel is requested" do
    token = 'token123'
    publisher = publishers(:google_verified)
    channel_id = 'yt123'
    channel_data = { 'id' => channel_id }

    stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?id=#{channel_id}&part=statistics,snippet").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'Authorization' => "Bearer #{token}",
                     'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

    assert_equal channel_data, YoutubeChannelGetter.new(publisher: publisher, token: token, channel_id: channel_id).perform
  end

  test "raises a ChannelForbiddenError when a particular channel is requested but can not be accessed" do
    token = 'token123'
    publisher = publishers(:google_verified)
    channel_id = 'yt123'
    channel_data = { 'id' => channel_id }

    stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?id=#{channel_id}&part=statistics,snippet").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'Authorization' => "Bearer #{token}",
                     'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 403, headers: {})

    assert_raises(YoutubeChannelGetter::ChannelForbiddenError) do
      YoutubeChannelGetter.new(publisher: publisher, token: token, channel_id: channel_id).perform
    end
  end

  test "raises a ChannelNotFoundError when a particular channel is requested but can not be found" do
    token = 'token123'
    publisher = publishers(:google_verified)
    channel_id = 'yt123'
    channel_data = { 'id' => channel_id }

    stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?id=#{channel_id}&part=statistics,snippet").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'Authorization' => "Bearer #{token}",
                     'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 404, headers: {})

    assert_raises(YoutubeChannelGetter::ChannelNotFoundError) do
      YoutubeChannelGetter.new(publisher: publisher, token: token, channel_id: channel_id).perform
    end
  end

  test "raises a ChannelBadRequestError when a particular channel is requested but an unexpected error is raised" do
    token = 'token123'
    publisher = publishers(:google_verified)
    channel_id = 'yt123'
    channel_data = { 'id' => channel_id }

    stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?id=#{channel_id}&part=statistics,snippet").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'Authorization' => "Bearer #{token}",
                     'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 400, headers: {})

    assert_raises(YoutubeChannelGetter::ChannelBadRequestError) do
      YoutubeChannelGetter.new(publisher: publisher, token: token, channel_id: channel_id).perform
    end
  end
end