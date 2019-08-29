class Sync::Zendesk::TicketCommentsToNotes
  include Sidekiq::Worker

  # https://developer.zendesk.com/rest_api/docs/support/ticket_comments#list-comments
  def perform(zendesk_ticket_id, page_number = 0)
    Rails.logger.info "Starting zendesk ticket #{zendesk_ticket_id}"
    require 'zendesk_api'
    client = ZendeskAPI::Client.new do |config|
      # Mandatory:
      config.url = "#{Rails.application.secrets[:zendesk_url]}/api/v2" # e.g. https://mydesk.zendesk.com/api/v2

      # Basic / Token Authentication
      config.username = "#{Rails.application.secrets[:zendesk_username]}/token"

      # Choose one of the following depending on your authentication choice
      # config.token = "your zendesk token"
      config.token = Rails.application.secrets[:zendesk_access_token]
      # config.password = "your zendesk password"

      # OAuth Authentication
      # config.access_token = ""

      # Optional:

      # Retry uses middleware to notify the user
      # when hitting the rate limit, sleep automatically,
      # then retry the request.
      config.retry = true
    end

    publisher_notes = []
    publisher = nil
    admin = Publisher.find_by(email: Rails.application.secrets[:zendesk_admin_email])
    zendesk_comments = client.ticket.find(id: zendesk_ticket_id).comments
    for index in (0...zendesk_comments.count)
      from_email = nil
      to_email = nil

      # The first email should be the publisher's email. Would be surprising otherwise
      comment = zendesk_comments[index]
      from_email = comment&.via&.source&.from&.address
      to_email = comment&.via&.source&.to&.address

      if (from_email.present? || to_email.present?) && publisher.nil?
        publisher = Publisher.find_by(email: from_email)
        publisher = Publisher.find_by(email: to_email) if publisher.nil?
      end

      publisher_note = PublisherNote.find_or_initialize_by(zendesk_ticket_id: zendesk_ticket_id, zendesk_comment_id: comment.id)
      publisher_note.created_at = comment.created_at
      publisher_note.created_by_id = admin.id
      publisher_note.note = comment.plain_body
      publisher_note.zendesk_from_email = from_email
      publisher_note.zendesk_to_email = to_email
      publisher_notes << publisher_note
    end

    # Don't lock this in a transaction as we might need to parse over to update the ticket
    publisher_notes.each do |pn|
      begin
        pn.publisher_id = publisher.id
        pn.save
      rescue ActiveRecord::RecordNotUnique
      end
    end

    Rails.logger.info "Done with zendesk ticket #{zendesk_ticket_id}"
  end
end
