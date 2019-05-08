require 'test_helper'
require 'vcr'

class Sync::Zendesk::TicketsToNotesTest < ActiveJob::TestCase
  test "find tickets from zendesk" do
    p "hello world"
    p Rails.application.secrets[:zendesk_url]
    VCR.use_cassette("test_reading_zendesk_tickets") do
      start_date = nil
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
        config.retry = true
      end

      response = client.search(
        query:
          "type:ticket " +
          "group_id:#{Rails.application.secrets[:zendesk_publisher_group_id]}" +
          (start_date.present? ? " updated>#{start_date}" : "")
      )
      assert response.count, 1
    end
  end

  test "find comments found on zendesk" do
    VCR.use_cassette("test_reading_zendesk_comments_from_a_ticket_backup") do
      PublisherNote.destroy_all
      admin = publishers(:zendesk_admin)
      publisher = publishers(:notes)
      assert PublisherNote.count, 0
      Sync::Zendesk::TicketCommentsToNotes.new.perform(2, 0)
      assert PublisherNote.count, 4

      # Assure there aren't duplicates made
      Sync::Zendesk::TicketCommentsToNotes.new.perform(2, 0)
      assert PublisherNote.count, 4
    end
  end
end
