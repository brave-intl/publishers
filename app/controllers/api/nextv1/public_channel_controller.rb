class Api::Nextv1::PublicChannelController < Api::Nextv1::BaseController
  skip_before_action :authenticate_publisher!

  def show
    channel = Channel.includes(:site_banner).find_by(public_identifier: params[:public_identifier])
    channel_title = channel&.publication_title
    crypto_addresses = channel&.crypto_addresses&.pluck(:address, :chain)

    # Handle the case when the resource is not found
    if channel.nil? || @crypto_addresses&.empty?
      return render json: {}, status: 404
    end

    begin
      url = channel.details&.url
      site_banner = channel.site_banner&.read_only_react_property || SiteBanner.new_helper(current_publisher.id, channel.id).read_only_react_property

      crypto_constants = {
        solana_main_url: ENV["SOLANA_MAIN_URL"],
        solana_bat_address: ENV["SOLANA_BAT_ADDRESS"],
        eth_bat_address: ENV["ETH_BAT_ADDRESS"],
        eth_usdc_address: ENV["ETH_USDC_ADDRESS"],
        solana_usdc_address: ENV["SOLANA_USDC_ADDRESS"]
      }

      response_data = {
        url: url,
        site_banner: site_banner,
        crypto_addresses: crypto_addresses,
        title: channel_title,
        crypto_constants: crypto_constants
      }

      render(json: response_data.to_json, status: 200)
    rescue => e
      LogException.perform(e)
      render(json: {errors: "channel information not found"}, status: 400)
    end
  end

  def get_ratios
    ratios = Ratio::Ratio.channel_page_cached
    render json: ratios["payload"]
  end
end