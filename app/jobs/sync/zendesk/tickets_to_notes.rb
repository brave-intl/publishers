class Sync::Zendesk::TicketsToNotes < ApplicationJob
  queue_as :default

  def perform(page_number = 0)
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

      # Logger prints to STDERR by default, to e.g. print to stdout:
      require 'logger'
      config.logger = Logger.new(STDOUT)

      # Changes Faraday adapter
      # config.adapter = :patron

      # Merged with the default client options hash
      # config.client_options = { :ssl => false }

      # When getting the error 'hostname does not match the server certificate'
      # use the API at https://yoursubdomain.zendesk.com/api/v2
    end

    # (Albert Wang): Are tickets collapsed?
    response = client.search(query: "type:ticket group_id:360001946832 sort_by:created_at sort_order:asc").per_page(50)
    # TODO: Tweak to measure comments
    # https://developer.zendesk.com/rest_api/docs/support/ticket_comments#list-comments
    response[:results].each do |result|
      publisher = Publisher.find_by(email: result[:via][:source][:from][:address])
      PublisherNote.create(note: "#{result[:subject]}\n#{result[:description]}", zendesk_ticket_id: result[:id], publisher_id: publisher.id, zendesk_comment_id: todo) if publisher.present?
    end

    Sync::Sidekiq::TicketsToNotes.perform_in(5.seconds, page_number + 1) if page_number <= results[:count]
  end
end
