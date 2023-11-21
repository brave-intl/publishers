class PublicChannelController < ApplicationController
  before_action :authenticate_publisher!

  def show
    channel = Channel.includes(:site_banner).find_by(public_identifier: params[:public_identifier])
    @url = channel.details.url
    @site_banner = channel.site_banner&.read_only_react_property || SiteBanner.new_helper(current_publisher.id, channel.id)
    @crypto_addresses = channel.crypto_addresses.pluck(:address, :chain)

    @crypto_constants = {
      solana_test_url: ENV["SOLANA_TEST_URL"],
      solana_main_url: ENV["SOLANA_MAIN_URL"],
      solana_bat_address: ENV["SOLANA_BAT_ADDRESS"],
      eth_bat_address: ENV["ETH_GOERLI_BAT_ADDRESS"]
    }

    # Handle the case when the resource is not found
    if channel.nil? || @crypto_addresses.empty? || !current_publisher.feature_flags["p2p_enabled"]
      redirect_to root_path, alert: "Channel not found"
    end
  end

  def get_ratios
    ratios = Ratio::Ratio.channel_page_cached
    render json: ratios["payload"]
  end
end
