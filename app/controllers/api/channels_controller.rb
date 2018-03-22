class Api::ChannelsController < Api::BaseController
  before_action :require_owner,
                only: %i(verify notify show)

  before_action :require_channel,
                only: %i(verify notify show)

  include PublishersHelper

  def notify
    if params[:type].blank?
      return render(status: 400, json: { message: "parameter 'type' is required" })
    end

    PublisherNotifier.new(
      notification_params: params[:params],
      notification_type: params[:type],
      publisher: @owner,
      channel: @channel
    ).perform
    render(json: { message: "success" })
  rescue PublisherNotifier::InvalidNotificationTypeError => error
    render(json: { message: error.message }, status: 400)
  end

  def verify
    if params[:verificationId].blank?
      return render(status: 400, json: { message: "parameter 'verificationId' is required" })
    end

    if params[:verificationId] != @channel.id
      return render(status: 400, json: { message: "parameter 'verificationId' does not match the channel id" })
    end

    if params[:verified].nil?
      return render(status: 400, json: { message: "parameter 'verified' is required" })
    end

    # Only set verified to true, and only if the channel is not already verified. This keeps verified from flipping
    # back and forth resulting in sending the verified notification repeatedly.
    # Eyeshade calls this endpoint in response to a `GET /v1/owners/{owner}/verify/{publisher}` call.
    # Because of this we will send notification emails from the SiteChannelVerifier instead of here.
    if !@channel.verified && params[:verified]
      success = @channel.update!(verified: true)
    else
      success = true
    end

    if success
      head :no_content
    else
      render(json: { errors: @channel.errors }, status: 400)
    end
  end

  def show
    render(json: @channel.details)
  end

  private

  def require_owner
    owner_id = publisher_id_from_owner_identifier(params[:owner_id])
    @owner = Publisher.find(owner_id)

    return @owner if @owner
    response = {
        error: "Invalid owner",
        message: "Can't find an owner with ID #{params[:owner_id]}"
    }
    render(json: response, status: 404)
  end

  def require_channel
    raise "Missing owner" if @owner.nil?
    @channel = @owner.channels.by_channel_identifier(params[:channel_id]).first

    return @channel if @channel
    response = {
      error: "Invalid channel",
      message: "Can't find a channel with ID #{params[:channel_id]}"
    }
    render(json: response, status: 404)
  end
end
