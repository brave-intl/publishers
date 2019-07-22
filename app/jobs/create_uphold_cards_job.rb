# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection:)
    unless uphold_connection.can_create_uphold_cards?
      # Reasons might include that they are not in a district which allows for crypto, like tennesse
      Rails.logger.info("Could not create uphold card for publisher #{uphold_connection.publisher_id}.")
      SlackMessenger.new(message: "Could not create uphold card for publisher #{uphold_connection.publisher_id}.", channel: SlackMessenger::ALERTS).perform
      return
    end

    default_currency = uphold_connection.default_currency

    # Search for an existing card
    card = uphold_connection.uphold_client.card.where(uphold_connection, default_currency).first

    if card.blank?
      # The card didn't exist so we should create it
      card = uphold_connection.uphold_client.card.create(uphold_connection, default_currency)
    end

    # Finally let's update the address with the id of the card
    uphold_connection.update(address: card.id)
  end
end
