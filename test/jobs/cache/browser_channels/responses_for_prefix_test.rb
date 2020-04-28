require 'test_helper'

class Cache::BrowserChannels::ResponsesForPrefixTest < ActiveJob::TestCase
  test 'creates basic responses list and can decompress back' do
    channel = channels(:verified)
    channel.send(:update_sha2_lookup)
    site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
    assert site_banner_lookup.present?

    service = Cache::BrowserChannels::ResponsesForPrefix.new
    service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, Cache::BrowserChannels::Main::RESPONSES_PREFIX_LENGTH])
    assert service.temp_file.present?
    require 'brotli'
    result_json = Brotli.inflate(File.open(service.temp_file.path, 'rb').readlines[0])
    result = PublishersPb::ChannelResponses.decode_json(result_json)
    assert_equal result.channel_response[0].channel_identifier, channel.details.channel_identifier
  end

  test 'complex responses list and can decompress back' do
    channel = channels(:verified)
    channel.send(:update_sha2_lookup)
    other_channel = channels(:google_verified)
    other_channel.send(:update_sha2_lookup)

    prefix = channel.site_banner_lookup.sha2_base16[0, Cache::BrowserChannels::Main::RESPONSES_PREFIX_LENGTH] 
    require 'byebug'
    # Update SHA2
    new_sha = prefix + other_channel.site_banner_lookup.sha2_base16[Cache::BrowserChannels::Main::RESPONSES_PREFIX_LENGTH, other_channel.site_banner_lookup.sha2_base16.length]
    other_channel.site_banner_lookup.update(sha2_base16: new_sha)

    service = Cache::BrowserChannels::ResponsesForPrefix.new
    service.generate_brotli_encoded_channel_response(prefix: prefix)
    assert service.temp_file.present?
    result_json = Brotli.inflate(File.open(service.temp_file.path, 'rb').readlines.join(""))
    result = PublishersPb::ChannelResponses.decode_json(result_json)
    assert_equal result.channel_response[0].channel_identifier, channel.details.channel_identifier
    assert_equal result.channel_response[1].channel_identifier, other_channel.details.channel_identifier
  end

  test 'padding for responses list can be added and stripped' do

  end
end
