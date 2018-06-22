class Admin::Publishers::PublisherStatusUpdatesController < Admin::PublishersController
  def index
    get_publisher
    @publisher_status_updates = @publisher.status_updates
  end

  def create
    @publisher.status_updates.create(status: params[:publisher_status])
    @publisher.reload
    flash[:notice] = "Updated publisher's status to #{@publisher.inferred_status}"
    redirect_to admin_publisher_path(id: @publisher.id)
  end
end
