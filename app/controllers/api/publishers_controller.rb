class Api::PublishersController < Api::BaseController
  before_action :require_verified_publisher, only: %i(notify)

  def notify
    PublisherNotifier.new(
      notification_params: params[:params],
      notification_type: params[:type],
      publisher: @publisher
    ).perform
    render(json: { message: "success" })
  rescue PublisherNotifier::InvalidNotificationTypeError => error
    render(json: { message: error.message, status: 400 })
  end

  def index_by_brave_publisher_id
    publishers = Publisher.where(
      brave_publisher_id: params[:brave_publisher_id]
    )
    render(json: publishers)
  end

  private

  def require_verified_publisher
    @publisher = Publisher.find_by(
      brave_publisher_id: params[:brave_publisher_id],
      verified: true
    )
    return @publisher if @publisher
    response = {
      error: "Invalid publisher",
      message: "Can't find a verified publisher with ID #{params[:brave_publisher_id]}"
    }
    render(json: response, status: 404)
  end
end
