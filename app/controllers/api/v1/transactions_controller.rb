class Api::V1::TransactionsController < Api::BaseController
  class GetTransactionError < StandardError; end

  def show
    channel = get_channel!(params[:channel])
    transaction = UpholdClient.transaction.find(
      id: params[:id],
      uphold_connection: channel.publisher.uphold_connection
    )

    render json: transaction
  rescue GetTransactionError => e
    render json: {errors: e.message}, status: 404
  rescue Faraday::ResourceNotFound
    render json: {errors: "Could not find the specified transaction under the publishers account"}, status: 400
  end

  def get_channel!(channel)
    raise GetTransactionError.new("Missing channel query parameter.") if channel.blank?

    channel = Channel.find_by_channel_identifier(channel)

    raise GetTransactionError.new("Could not find channel. Did you encode the identifier?") if channel.blank?
    raise GetTransactionError.new("Channel does not have connected Uphold account") if channel.publisher&.uphold_connection.blank?
    channel
  end
end
