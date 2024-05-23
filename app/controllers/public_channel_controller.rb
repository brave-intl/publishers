class PublicChannelController < ApplicationController
  layout "public"

  def show
    channel = Channel.includes(:site_banner).find_by(public_identifier: params[:public_identifier])
    # channel_title is used in the meta tags
    @channel_title = channel&.publication_title
    @crypto_addresses = channel&.crypto_addresses&.pluck(:address, :chain)

    # Handle the case when the resource is not found
    if channel.nil? || @crypto_addresses.empty?
      redirect_to root_path, alert: "Channel not found"
      return
    end
    @url = channel.details&.url
    @site_banner = channel.site_banner&.read_only_react_property || SiteBanner.new_helper(current_publisher.id, channel.id)

    @crypto_constants = {
      solana_main_url: ENV["SOLANA_MAIN_URL"],
      solana_bat_address: ENV["SOLANA_BAT_ADDRESS"],
      eth_bat_address: ENV["ETH_BAT_ADDRESS"],
      eth_usdc_address: ENV["ETH_USDC_ADDRESS"],
      solana_usdc_address: ENV["SOLANA_USDC_ADDRESS"]
    }
  end

  def get_ratios
    ratios = Ratio::Ratio.channel_page_cached
    render json: ratios["payload"]
  end
end
