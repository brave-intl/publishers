class Api::ChannelsController < Api::BaseController
  before_action :require_channel,
                only: %i(verify notify show)

  include PublishersHelper

  # def notify
  #   if params[:type].blank?
  #     return render(status: 400, json: { message: "parameter 'type' is required" })
  #   end
  #
  #   PublisherNotifier.new(
  #     notification_params: params[:params],
  #     notification_type: params[:type],
  #     publisher: @publisher,
  #     channel: @channel
  #   ).perform
  #   render(json: { message: "success" })
  # rescue PublisherNotifier::InvalidNotificationTypeError => error
  #   render(json: { message: error.message }, status: 400)
  # end

  def verify
    success = @channel.update(verified: true)

    if success
      head :no_content
    else
      render(json: { errors: @channel.errors }, status: 400)
    end
  end

  def show
    render(json: @channel, include: "details")
  end

  private

  def require_channel
    if params[:owner_id]
      owner_id = publisher_id_from_owner_identifier(params[:owner_id])
      publisher = Publisher.find(owner_id)
      @channel = publisher.channels.by_channel_identifier(params[:channel_id])
    else
      @channel = Channel.by_channel_identifier(params[:channel_id]).first
    end
    return @channel if @channel
    response = {
      error: "Invalid channel",
      message: "Can't find a channel with ID #{params[:channel_id]}"
    }
    render(json: response, status: 404)
  end
end
