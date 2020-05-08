class Api::V1::PublishersController < Api::BaseController
  class InvalidNote < StandardError; end
  class InvalidAdmin < StandardError; end
  def show
    publisher = Publisher.find(params[:id])
    current_status_update = publisher.last_status_update
    data = {
      id: publisher.id,
      owner_identifier: publisher.owner_identifier,
      email: publisher.email,
      name: publisher.name,
      created_at: publisher.created_at,
      current_status: {
        status: current_status_update.status,
        created_at: current_status_update.created_at,
      },
    }
    render(status: 200, json: data) and return

  rescue ActiveRecord::RecordNotFound
    error_response = {
      errors: [{
        status: "404",
        title: "Not Found",
        detail: "Publisher with id #{params[:publisher_id]} not found",
      },],
    }

    render(status: 404, json: error_response) and return
  end

  def publisher_status_updates
    user = Publisher.find(params[:publisher_id])
    admin = Publisher.find_by_email(params[:admin])
    status = params[:status]
    note = params[:note]

    raise InvalidNote if note.blank?
    raise InvalidAdmin if admin.blank?

    status_update = PublisherStatusUpdate.create!(publisher: user, status: status)
    PublisherNote.create!(note: note, publisher: user, created_by: admin)

    # Email users who were put on hold via the API
    PublisherMailer.email_user_on_hold(@publisher).deliver_later if status == PublisherStatusUpdate::HOLD

    render(status: 200, json: { publisher_status_updates_id: status_update.id }) and return

  rescue ActiveRecord::RecordInvalid
    error_response = {
      error: "Status Invalid",
      detail: "Status #{params[:status]} is not valid, please use one of the following: #{PublisherStatusUpdate::ALL_STATUSES.join(", ")}",
    }

    render(status: 404, json: error_response) and return

  rescue InvalidNote
    error_response = {
      error: "Note Invalid",
      detail: "Note cannot be null, please provide justification for status update",
    }

    render(status: 404, json: error_response) and return

  rescue InvalidAdmin
    error_response = {
      error: "Admin Invalid",
      detail: "Admin field cannot be null, please provide e-mail of an admin",
    }

    render(status: 404, json: error_response) and return

  rescue ActiveRecord::RecordNotFound
    error_response = {
      error: "Not Found",
      detail: "Publisher with id #{params[:publisher_id]} not found",
    }

    render(status: 404, json: error_response) and return
  end
end
