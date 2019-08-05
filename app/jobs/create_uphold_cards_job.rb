# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:)
    uphold_connection = UpholdConnection.find(uphold_connection_id)
    unless uphold_connection.can_create_uphold_cards?
      Rails.logger.info("Could not create uphold card for publisher #{uphold_connection.publisher_id}. Uphold Verified: #{uphold_connection.uphold_verified}")
      return
    end

    # Search for an existing card
    card = uphold_connection.uphold_client.card.where(uphold_connection: uphold_connection)&.first

    # If the card doesn't exist so we should create it
    if card.blank?
      Rails.logger.info("Could not find existing card for #{uphold_connection.default_currency} - Creating a new card")
      card = uphold_connection.uphold_client.card.create(uphold_connection: uphold_connection)
    end

    # Finally let's update the address with the id of the card
    uphold_connection.update(address: card.id)
  end
end
