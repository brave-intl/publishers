class Admin::Publishers::PublisherStatusUpdatesController < Admin::PublishersController
  def index
    get_publisher
    @publisher_status_updates = @publisher.status_updates
  end

  def create
    @publisher.status_updates.create(status: params[:publisher_status])
    redirect_to :back
  end
end
