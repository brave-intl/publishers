# typed: ignore

class Api::V3::ChannelsController < Api::BaseController
  # Takes an array of channel identifiers and retuns a dictionary of channel identifiers as keys and true/false as values
  def allowed_countries
    channels = params[:channel_ids].map do |id|
      {channel: Channel.find_fully_verified_by_channel_identifier(id), channel_identifier: id}
    end

    response = {}
    channels || [].each do |channel_obj|
      publisher = channel_obj[:channel]&.publisher

      next response[channel_obj[:channel_identifier]] = false if !publisher

      wallet = publisher.selected_wallet_provider
      response[channel_obj[:channel_identifier]] = case wallet
      when GeminiConnection, UpholdConnection
        wallet.valid_country?
      when BitflyerConnection
        wallet.present?
      else
        raise "Unknown wallet connection"
      end
    end

    # is there any metadata we need here?
    render(json: response.to_json, status: 200)
  end

  def authenticate_ip
    true
  end
end
