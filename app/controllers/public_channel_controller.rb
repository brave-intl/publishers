class PublicChannelController < ApplicationController
  before_action :authenticate_publisher!

  def show
    @channel = Channel.includes(:site_banner).find_by(public_identifier: params[:public_identifier])
    @site_banner = @channel.site_banner&.read_only_react_property || current_publisher.default_site_banner&.read_only_react_property
    @crypto_addresses = @channel.crypto_addresses.pluck(:address, :chain)

    # Handle the case when the resource is not found
    if @channel.nil? || @crypto_addresses.empty? || current_publisher != @channel.publisher || !current_publisher.feature_flags["p2p_enabled"]
      redirect_to root_path, alert: "Channel not found"
    end
  end
end
