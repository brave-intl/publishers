class Api::V1::Private::PublishersController < Api::V1::Private::BaseController
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
    publisher = Publisher.find(params[:publisher_id])
    status = params[:status]

    PublisherStatusUpdate.create!(publisher_id: publisher.id, status: status)
    data = { "hi": publisher.last_status_update.status }

    render(status: 200, json: data) and return
  rescue ActiveRecord::RecordInvalid
    error_response = {
      errors: [{
        status: "404",
        title: "Not Found",
        detail: "Status #{params[:status]} is not valid, please use one of the following: #{PublisherStatusUpdate::ALL_STATUSES.join(", ")}",
      },],
    }

    render(status: 404, json: error_response) and return

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
end
