class Api::ChannelsController < Api::BaseController
  before_action :require_owner,
                only: %i(verify notify show create)

  before_action :require_channel,
                only: %i(verify notify show)

  before_action :ensure_json_content_type,
                only: %i(create)

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
    render(json: @channel.details, status: :ok)
  end

  def create
    channel = Channel.new(publisher: @owner, verified: true, created_via_api: true)

    channel.details = SiteChannelDetails.new(site_channel_details_params)

    SiteChannelDomainSetter.new(channel_details: channel.details).perform

    channel.save!

    # once the channel has been saved send it to eyeshade
    begin
      PublisherChannelSetter.new(publisher: @owner).perform
    rescue => e
      require "sentry-raven"
      Raven.capture_exception(e)
    end

    render(json: channel.details, status: :ok)
  end

  private

  def require_owner
    owner_id = publisher_id_from_owner_identifier(params[:owner_id])
    @owner = Publisher.where(id: owner_id).first

    return @owner if @owner
    response = {
        error: "Invalid owner",
        message: "Can't find an owner with ID #{params[:owner_id]}"
    }
    render(json: response, status: :not_found)
  end

  def require_channel
    raise "Missing owner" if @owner.nil?
    @channel = @owner.channels.by_channel_identifier(params[:channel_id]).first

    return @channel if @channel
    response = {
      error: "Invalid channel",
      message: "Can't find a channel with ID #{params[:channel_id]}"
    }
    render(json: response, status: :not_found)
  end

  private

  def site_channel_details_params
    details_params = params[:channel].permit(:brave_publisher_id)
    details_params
  end
end
