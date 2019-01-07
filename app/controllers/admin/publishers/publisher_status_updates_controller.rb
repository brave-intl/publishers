class Admin::Publishers::PublisherStatusUpdatesController < Admin::PublishersController
  def index
    get_publisher
    @publisher_status_updates = @publisher.status_updates
  end

  def create
    @publisher.status_updates.create(status: params[:publisher_status])
    @publisher.reload

    # TODO: Send emails for other manual status updates, and send email without creating a status update
    if params[:publisher_status] == "suspended" && params[:send_email].present?
      PublisherMailer.suspend_publisher(@publisher).deliver_later
    end

    flash[:notice] = "Updated publisher's status to #{@publisher.inferred_status}"
    redirect_to admin_publisher_path(id: @publisher.id)
  end
end
