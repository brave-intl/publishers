class Api::ChannelsController < Api::BaseController
  before_action :require_owner,
                only: %i(notify show create)

  before_action :require_channel,
                only: %i(notify show)

  before_action :ensure_json_content_type,
                only: %i(create)
  before_action :get_current_channel, only: :verification_status

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

  def verification_status
    if @current_channel.verified?
      render(
        json: {
          status: "success",
          verificationId: @current_channel.id
        },
        status: :ok
      ) and return
    else
      render(
        json: {
          status: "failure"
        },
        status: :ok
      ) and return
    end
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

  def get_current_channel
    @current_channel = Channel.find(params[:channel_id])
  end
end
