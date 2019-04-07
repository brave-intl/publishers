class Sync::Zendesk::TicketCommentsToNotes < ApplicationJob
  queue_as :default

  # https://developer.zendesk.com/rest_api/docs/support/ticket_comments#list-comments
  def perform(zendesk_ticket_id, page_number = 0)
    require 'zendesk_api'
    return if Rails.env.development?

    client = ZendeskAPI::Client.new do |config|
      # Mandatory:
      config.url = "#{Rails.application.secrets[:zendesk_url]}/api/v2" # e.g. https://mydesk.zendesk.com/api/v2

      # Basic / Token Authentication
      config.username = Rails.application.secrets[:zendesk_username]

      # Choose one of the following depending on your authentication choice
      # config.token = "your zendesk token"
      # config.password = "your zendesk password"

      # OAuth Authentication
      config.access_token = Rails.application.secrets[:zendesk_access_token]

      # Optional:

      # Retry uses middleware to notify the user
      # when hitting the rate limit, sleep automatically,
      # then retry the request.
      config.retry = true
    end

    publisher_notes = []
    publisher = nil
    for index in (0...client.ticket.find(id: zendesk_ticket_id).comments.count)
      comment = client.ticket.find(id: zendesk_ticket_id).comments[index]
      publisher_email = comment&.via&.source&.from&.address
      if publisher_email.present? && publisher.nil?
        publisher = Publisher.find_by(email: publisher_email)
      end
      publisher_notes << PublisherNote.new(note: comment.plain_body, zendesk_ticket_id: zendesk_ticket_id, zendesk_comment_id: comment.id, created_at: comment.created_at)
    end
    ActiveRecord::Base.transaction do
      publisher_notes.each do |publisher_note|
        publisher_note.publisher_id = publisher.id
        publisher_note.save
      end
    end
  end
end
