# typed: false

require "test_helper"
require "jobs/sidekiq_test_case"

class Cache::BrowserChannels::ResponsesForPrefixTest < SidekiqTestCase
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

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

  test "Does not send wallet addresses for connections not on the regional allowlist" do
    channel = channels(:verified_blocked_country)
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

    assert_equal result.channel_responses[0].channel_identifier, channel.details.channel_identifier
    assert_predicate result.channel_responses[0].wallets[0].uphold_wallet.address, :empty?
  end

  test "Matches the wallet info to the selected wallet provider, even when there are multiple connections" do
    channel = channels(:gemini_completed_website)
    uphold_connection = uphold_connections(:base_verified_connection)
    uphold_connection.publisher = channel.publisher

    assert_predicate channel.publisher.gemini_connection, :present?
    assert_predicate channel.publisher.uphold_connection, :present?

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

    assert_equal result.channel_responses[0].channel_identifier, channel.details.channel_identifier
    assert_equal result.channel_responses[0].wallets.length, 1
    assert_equal result.channel_responses[0].wallets[0].gemini_wallet.address, channel.gemini_connection.recipient_id
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
    assert_equal result.channel_responses[0].site_banner_details.web3Url, ""
  end

  # test "solana wallet generation" do
  #   channel = channels(:verified)
  #   channel.send(:update_site_banner_lookup!)
  #   site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
  #   assert site_banner_lookup.present?

  #   service = Cache::BrowserChannels::ResponsesForPrefix.new
  #   ActiveRecord::Base.connected_to(role: :reading) do
  #     service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES])
  #   end
  #   assert service.temp_file.present?
  #   result = Brotli.inflate(File.open(service.temp_file.path, "rb").readlines.join("").slice(4..-1))
  #   result = PublishersPb::ChannelResponseList.decode(result)
  #   assert result.channel_responses[0].wallets[0].uphold_wallet.address
  #   assert_equal result.channel_responses[0].wallets[1].solana_wallet.address, channel.crypto_address_for_channels.sol_addresses.first.crypto_address.address
  #   assert_equal result.channel_responses[0].channel_identifier, channel.details.channel_identifier
  #   # in the test environment, the creators_host env variable is nil
  #   assert_equal result.channel_responses[0].site_banner_details.web3Url, "/c/123456dfg6"
  # end

  # test "ethereum wallet generation" do
  #   channel = channels(:verified)
  #   channel.send(:update_site_banner_lookup!)
  #   site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
  #   assert site_banner_lookup.present?

  #   service = Cache::BrowserChannels::ResponsesForPrefix.new
  #   ActiveRecord::Base.connected_to(role: :reading) do
  #     service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES])
  #   end
  #   assert service.temp_file.present?
  #   result = Brotli.inflate(File.open(service.temp_file.path, "rb").readlines.join("").slice(4..-1))
  #   result = PublishersPb::ChannelResponseList.decode(result)
  #   assert result.channel_responses[0].wallets[0].uphold_wallet.address
  #   assert_equal result.channel_responses[0].wallets[2].ethereum_wallet.address, channel.crypto_address_for_channels.eth_addresses.first.crypto_address.address
  #   assert_equal result.channel_responses[0].channel_identifier, channel.details.channel_identifier
  #   assert_equal result.channel_responses[0].site_banner_details.web3Url, "/c/123456dfg6"
  # end

  test "channel details includes web3 address" do
    
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

    test "nil Uphold addresses should not result in ProtoBuf errors" do
      channel = channels(:verified)
      channel.send(:update_site_banner_lookup!)
      site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
      assert site_banner_lookup.present?

      channel.publisher.uphold_connection.uphold_connection_for_channels.each { |ucc| ucc.update!(address: nil) }

      service = Cache::BrowserChannels::ResponsesForPrefix.new
      ActiveRecord::Base.connected_to(role: :reading) do
        service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES])
      end
      assert service.temp_file.present?
      result = Brotli.inflate(File.open(service.temp_file.path, "rb").readlines.join("").slice(4..-1))
      result = PublishersPb::ChannelResponseList.decode(result)

      assert_equal result.channel_responses[0].wallets[0].uphold_wallet.address, ""
    end

    test "nil Gemini addresses should not result in ProtoBuf errors" do
      channel = channels(:gemini_completed_website)
      channel.send(:update_site_banner_lookup!)
      site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
      assert site_banner_lookup.present?

      channel.publisher.gemini_connection.gemini_connection_for_channels.each { |gcc| gcc.update(recipient_id: nil) }

      service = Cache::BrowserChannels::ResponsesForPrefix.new
      ActiveRecord::Base.connected_to(role: :reading) do
        service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES])
      end
      assert service.temp_file.present?
      result = Brotli.inflate(File.open(service.temp_file.path, "rb").readlines.join("").slice(4..-1))
      result = PublishersPb::ChannelResponseList.decode(result)

      assert_equal result.channel_responses[0].wallets[0].gemini_wallet.address, ""
    end

    # test "generating channel response should fail where country information could not be loaded" do
    #   Rails.cache.clear

    #   stub_request(:get, "#{Rails.application.secrets[:api_rewards_base_uri]}/v1/parameters")
    #     .to_return(status: 400, body: "")

    #   channel = channels(:verified)
    #   channel.send(:update_site_banner_lookup!)
    #   site_banner_lookup = SiteBannerLookup.find_by(channel_id: channel.id)
    #   assert site_banner_lookup.present?

    #   service = Cache::BrowserChannels::ResponsesForPrefix.new
    #   assert_raises Faraday::ClientError do
    #     ActiveRecord::Base.connected_to(role: :reading) do
    #       Rails.cache.delete(Rewards::Client::RATES_CACHE_KEY)
    #       service.generate_brotli_encoded_channel_response(prefix: site_banner_lookup.sha2_base16[0, SiteBannerLookup::NIBBLE_LENGTH_FOR_RESPONSES])
    #     end
    #   end
    # end
  end
end
