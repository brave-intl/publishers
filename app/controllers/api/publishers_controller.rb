class Api::PublishersController < Api::BaseController
  before_action :require_verified_publisher,
                only: %i(notify)
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

  def notify_unverified
    PublisherNotifierUnverified.new(
      publisher_id: params[:publisher_id],
      publisher_type: params[:publisher_type],
    ).perform
    render(json: { message: "success" })

    rescue PublisherNotifierUnverified::InvalidPublisherTypeError, PublisherNotifierUnverified::BlankParamsError => error
      render(json: { message: error.message }, status: 400)
      
    rescue PublisherNotifierUnverified::NoEmailsFoundError => error
      render(json: { message: error.message }, status: 500)
  end

  def index_by_brave_publisher_id
    publishers = Publisher.where(
      brave_publisher_id: params[:brave_publisher_id]
    )
    render(json: publishers)
  end

  def create
    @publisher = Publisher.new(publisher_create_params)
    @publisher.created_via_api = true
    if @publisher.save
      if @publisher.verified
        PublisherMailer.verification_done(@publisher).deliver_later
        if PublisherMailer.should_send_internal_emails?
          PublisherMailer.verification_done_internal(@publisher).deliver_later
        end
      end
      render(json: { message: "success" })
    else
      render(json: { message: "error", errors: @publisher.errors }, status: 400)
    end
  end

  def destroy
    Publisher.where(brave_publisher_id: params[:brave_publisher_id], verified: false).destroy_all
    render(json: { message: "success" })
  end

  private

  def publisher_create_params
    params.require(:publisher).permit(:email, :brave_publisher_id, :name, :phone, :show_verification_status, :verified)
  end

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