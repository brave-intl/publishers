class Api::V1::PromoRegistrationsController < Api::BaseController
  class InvalidNote < StandardError; end
  class InvalidAdmin < StandardError; end

  def publisher_status_updates
    referral_code = params[:referral_code]
    publisher = Publisher.joins(:promo_registrations).where(promo_registrations: {referral_code: referral_code}).first
    raise ActiveRecord::RecordNotFound if publisher.nil?

    admin = Publisher.find_by_email(params[:admin])
    status = params[:status]
    note = params[:note]

    raise InvalidNote if note.blank?
    raise InvalidAdmin if admin.blank?

    status_update = PublisherStatusUpdate.create!(publisher: publisher, status: status)
    PublisherNote.create!(note: note, publisher: publisher, created_by: admin)

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
