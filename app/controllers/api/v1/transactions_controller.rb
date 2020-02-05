class Api::V1::TransactionsController < Api::BaseController
  class GetTransactionError < StandardError; end

  def show
    channel = get_merchant!(params[:merchant])
    uphold_client = Uphold::Client.new(uphold_connection: channel.publisher.uphold_connection)

    render json: uphold_client.transaction.find(id: params[:id])
  rescue GetTransactionError => e
    render json: { errors: e.message }, status: 404
  rescue Faraday::ResourceNotFound
    render json: { errors: "Could not find the specified transaction under the publishers account" }, status: 400
  end

  def get_merchant!(merchant)
    channel = Channel.site_channels.verified.find_by(site_channel_details: { brave_publisher_id: merchant })

    raise GetTransactionError.new("Could not find merchant") if channel.blank?
    raise GetTransactionError.new("Merchant does not have connected Uphold account") if channel.publisher&.uphold_connection.blank?
    channel
  end
end
