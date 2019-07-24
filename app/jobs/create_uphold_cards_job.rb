# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection:)
    unless uphold_connection.can_create_uphold_cards?
      # Not sure
      Rails.logger.info("Could not create uphold card for publisher #{uphold_connection.publisher_id}.")
      SlackMessenger.new(message: "Could not create uphold card for publisher #{uphold_connection.publisher_id}.", channel: SlackMessenger::ALERTS).perform
      return
    end

    # Search for an existing card
    card = uphold_connection.uphold_client.card.where(uphold_connection: uphold_connection).first

    # If the card doesn't exist so we should create it
    if card.blank?
      card = uphold_connection.uphold_client.card.create(uphold_connection: uphold_connection)
    end

    # Finally let's update the address with the id of the card
    uphold_connection.update(address: card.id)
  end
end
