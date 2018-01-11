class Api::OwnersController < Api::BaseController
  before_action :require_verified_publisher,
                only: %i(notify show)

  include PublishersHelper

  def notify
    if params[:type].blank?
      return render(status: 400, json: { message: "parameter 'type' is required" })
    end

    PublisherNotifier.new(
      notification_params: params[:params],
      notification_type: params[:type],
      publisher: @publisher
    ).perform
    render(json: { message: "success" })
  rescue PublisherNotifier::InvalidNotificationTypeError => error
    render(json: { message: error.message }, status: 400)
  end

  def show
    render(json: @publisher, include: "channels,channels.details")
  end

  private

  def require_verified_publisher
    owner_id = publisher_id_from_owner_identifier(params[:owner_id])

    @publisher = Publisher.find(owner_id)
    return @publisher if @publisher
    response = {
      error: "Invalid owner",
      message: "Can't find an owner with ID #{params[:owner_id]}"
    }
    render(json: response, status: 404)
  end
end
