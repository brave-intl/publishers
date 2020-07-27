require 'test_helper'

class Cache::BrowserChannels::PrefixListTest < ActiveSupport::TestCase
  def self.test_order
    # Runs in order
    # https://api.rubyonrails.org/v4.2.5/classes/ActiveSupport/TestCase.html
    :alpha
  end

  before do
    channels(:verified).update_site_banner_lookup!
    channels(:google_verified).update_site_banner_lookup!
  end

  test 'creates basic prefix list and can decompress back for no compression' do
    service = Cache::BrowserChannels::PrefixList.new(compression_type: PublishersPb::PublisherPrefixList::CompressionType::NO_COMPRESSION)
    temp_file = service.save_main_file!
    publishers_list_pb = PublishersPb::PublisherPrefixList.decode(File.open(temp_file.path, 'rb').readlines[0])
    prefixes = publishers_list_pb['prefixes'].chars.each_slice(publishers_list_pb['prefix_size']).map(&:join)
    assert_not_equal 0, prefixes.length
    assert_equal SiteBannerLookup.count, prefixes.length
  end

  test 'creates basic prefix list and can decompress back for brotli compression' do
    service = Cache::BrowserChannels::PrefixList.new(compression_type: PublishersPb::PublisherPrefixList::CompressionType::BROTLI_COMPRESSION)
    temp_file = service.save_main_file!
    prefixes_compressed = PublishersPb::PublisherPrefixList.decode(File.open(temp_file.path, 'rb').readlines[0])['prefixes']
    prefixes = Brotli.inflate(prefixes_compressed).unpack('H*')[0].scan(/.{#{Cache::BrowserChannels::PrefixList::PREFIX_LENGTH * 2}}/)
    assert_not_equal 0, prefixes.length
    assert_equal SiteBannerLookup.count, prefixes.length
    prefixes.each do |prefix|
      assert_not_equal SiteBannerLookup.where("sha2_base16 LIKE '#{prefix}%'").count, 0
    end
  end
end
