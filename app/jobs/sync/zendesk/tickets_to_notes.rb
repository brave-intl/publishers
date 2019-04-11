class Sync::Zendesk::TicketsToNotes
  include Sidekiq::Worker

  def perform(page_number = 0)
    require 'zendesk_api'
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

    # (Albert Wang): Don't bother with sorting. There's a bug in the app where it casts & into urlencoding. Zendesk should fix it on their
    # end or we make a fix on Zendesk's Ruby Gem
    response = client.search(query: "type:ticket group_id:#{Rails.application.secrets[:zendesk_publisher_group_id]}").per_page(50)
    response.all! do |result|
      Sync::Zendesk::TicketCommentsToNotes.perform_async(result[:id], 0)
    end

    Sync::Zendesk::TicketsToNotes.perform_in(30.seconds, page_number + 1) if page_number <= response.count
  end
end
