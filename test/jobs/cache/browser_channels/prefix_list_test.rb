require 'test_helper'

class Cache::BrowserChannels::PrefixListTest < ActiveSupport::TestCase
  def self.test_order
    # Runs in order
    # https://api.rubyonrails.org/v4.2.5/classes/ActiveSupport/TestCase.html
    :alpha
  end

  test 'creates basic prefix list and can decompress back' do
    service = Cache::BrowserChannels::PrefixList.new
    temp_file = service.save_main_file!
    prefixes_compressed = PublishersPb::PublisherList.decode(File.open(temp_file.path, 'rb').readlines[0])['prefixes']
    prefixes = JSON.parse(Brotli.inflate(prefixes_compressed))
    assert_equal SiteBannerLookup.where.not(wallet_status: PublishersPb::WalletConnectedState::NO_VERIFICATION).count, prefixes.length
  end
end
