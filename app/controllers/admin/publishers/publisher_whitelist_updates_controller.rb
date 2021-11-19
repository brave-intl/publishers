# typed: false
class Admin::Publishers::PublisherWhitelistUpdatesController < Admin::PublishersController
  def create
    note = @publisher.notes.create!(note: params[:note], created_by_id: current_publisher.id)
    PublisherWhitelistUpdate.create!(publisher: @publisher, enabled: params[:enable], publisher_note: note)
    @publisher.reload

    flash[:notice] = "Added publisher to whitelist."
    redirect_to admin_publisher_path(id: @publisher.id)
  end
end
