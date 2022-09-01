# typed: ignore

class Admin::Publishers::PublisherStatusUpdatesController < Admin::PublishersController
  def index
    get_publisher
    @navigation_view = Views::Admin::NavigationView.new(@publisher).as_json.merge({navbarSelection: "Dashboard"}).to_json
    @publisher_status_updates = @publisher.status_updates
  end

  def create
    if @publisher.last_whitelist_update&.enabled && [PublisherStatusUpdate::NO_GRANTS, PublisherStatusUpdate::SUSPENDED].include?(params[:publisher_status])
      render(status: 403, json: {reason: "Cannot suspend whitelisted publisher"}) and return
    end

    note = @publisher.notes.create(note: params[:note], created_by_id: current_publisher.id)
    @publisher.status_updates.create(status: params[:publisher_status], publisher_note: note)
    @publisher.reload

    # TODO: Send emails for other manual status updates, and send email without creating a status update
    if params[:send_email].present?
      case params[:publisher_status]
      when PublisherStatusUpdate::SUSPENDED
        PublisherMailer.suspend_publisher(@publisher).deliver_later
      when PublisherStatusUpdate::HOLD
        PublisherMailer.email_user_on_hold(@publisher).deliver_later
      end
    end

    if @publisher.only_user_funds?
      flash[:alert] = "FYI: The promo registrations have not been destroyed for this user - however they will not see their promotions"
    end

    flash[:notice] = "Updated publisher's status to #{@publisher.inferred_status}"
    redirect_to admin_publisher_path(id: @publisher.id)
  end
end
