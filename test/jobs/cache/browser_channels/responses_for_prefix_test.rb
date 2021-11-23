# typed: false
require "test_helper"
require "jobs/sidekiq_test_case"

class Cache::BrowserChannels::ResponsesForPrefixTest < SidekiqTestCase
  def self.test_order
    # Runs in order
    # https://api.rubyonrails.org/v4.2.5/classes/ActiveSupport/TestCase.html
    :alpha
  end

  test "creates basic responses list and can decompress back" do
    channel = channels(:verified)
    channel.send(:update_site_banner_lookup!)
    site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
    assert site_banner_lookup.present?

    service = Cache::BrowserChannels::ResponsesForPrefix.new
    ActiveRecord::Base.connected_to(role: :reading) do
      service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES])
    end
    assert service.temp_file.present?
    result = Brotli.inflate(File.open(service.temp_file.path, "rb").readlines.join("").slice(4..-1))
    result = PublishersPb::ChannelResponseList.decode(result)
    assert result.channel_responses[0].wallets[0].uphold_wallet.address
    assert_equal result.channel_responses[0].wallets[0].uphold_wallet.address, channel.uphold_connection.address
    assert_equal result.channel_responses[0].channel_identifier, channel.details.channel_identifier
  end

  test "gemini wallet generation" do
    channel = channels(:gemini_completed_website)
    channel.send(:update_site_banner_lookup!)
    site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
    assert site_banner_lookup.present?

    service = Cache::BrowserChannels::ResponsesForPrefix.new
    ActiveRecord::Base.connected_to(role: :reading) do
      service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES])
    end
    assert service.temp_file.present?
    result = Brotli.inflate(File.open(service.temp_file.path, "rb").readlines.join("").slice(4..-1))
    result = PublishersPb::ChannelResponseList.decode(result)
    assert_equal result.channel_responses[0].wallets[0].gemini_wallet.address, channel.gemini_connection_for_channel.first.recipient_id
    assert_equal result.channel_responses[0].channel_identifier, channel.details.channel_identifier
  end

  describe "complex channel response file generation" do
    before do
      @channel = channels(:verified)
      @channel.send(:update_site_banner_lookup!)
      @other_channel = channels(:google_verified)
      @other_channel.send(:update_site_banner_lookup!)

      prefix = @channel.site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES]
      # Update SHA2
      new_sha = prefix + @other_channel.site_banner_lookup.sha2_base16[SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES, @other_channel.site_banner_lookup.sha2_base16.length]
      @other_channel.site_banner_lookup.update(sha2_base16: new_sha)
      @service = Cache::BrowserChannels::ResponsesForPrefix.new
      ActiveRecord::Base.connected_to(role: :reading) do
        @service.generate_brotli_encoded_channel_response(prefix: prefix)
      end
    end

    test "decompress back and has matching responses" do
      res = File.open(@service.temp_file.path, "rb").readlines.join("")
      encoded_file_size = res.slice(0..3).unpack1("L")
      result_json = Brotli.inflate(res.slice(4..(encoded_file_size + 4)))
      result = PublishersPb::ChannelResponseList.decode(result_json)
      assert_equal result.channel_responses[0].channel_identifier, @channel.details.channel_identifier
      assert_equal result.channel_responses[1].channel_identifier, @other_channel.details.channel_identifier
    end

    test "padding for responses list is set to multiples of 1000" do
      original_file_size = File.size(@service.temp_file.path)
      @service.send(:pad_file!)
      assert_equal File.size(@service.temp_file.path), 1000
      assert_equal File.size(@service.temp_file.path) % 1000, 0
      assert_not_equal original_file_size, 1000
    end

    test "temp file gets deleted" do
      original_path = @service.temp_file.path
      @service.send(:cleanup!)
      assert_not File.file?(original_path)
    end
  end
end
