class Admin::Publishers::PublisherStatusUpdatesController < Admin::PublishersController
  def index
    get_publisher
    @navigation_view = Views::Admin::NavigationView.new(@publisher).as_json.merge({ navbarSelection: "Dashboard"}).to_json
    @publisher_status_updates = @publisher.status_updates
  end

  def create
    @publisher.status_updates.create(status: params[:publisher_status])
    if params[:note].present?
      @publisher.notes.create(note: params[:note], created_by_id: current_publisher.id)
    end
    @publisher.reload

    # TODO: Send emails for other manual status updates, and send email without creating a status update
    if params[:publisher_status] == "suspended" && params[:send_email].present?
      PublisherMailer.suspend_publisher(@publisher).deliver_later
    end

    flash[:notice] = "Updated publisher's status to #{@publisher.inferred_status}"
    redirect_to admin_publisher_path(id: @publisher.id)
  end
end
