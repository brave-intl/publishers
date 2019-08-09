# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:)
    uphold_connection = UpholdConnection.find(uphold_connection_id)
    unless uphold_connection.can_create_uphold_cards?
      Rails.logger.info("Could not create uphold card for publisher #{uphold_connection.publisher_id}. Uphold Verified: #{uphold_connection.uphold_verified}")
      return
    end

    # We create the cards, so let's first check to see if the publisher has an address so we might not have to change anything
    if uphold_connection.address.present?
      begin
        card = uphold_connection.uphold_client.card.find(uphold_connection: uphold_connection, id: uphold_connection.address)

        return if card&.currency.eql?(uphold_connection.default_currency)
      rescue Faraday::ResourceNotFound
        # This most likely won't ever happen because it's not possible to delete a card. Better safe than sorry.
      end
    end

    # Search for an existing card
    cards = uphold_connection.uphold_client.card.where(uphold_connection: uphold_connection)
    existing_private_cards = UpholdConnectionForChannel.select(:card_id).where(uphold_connection: uphold_connection).to_a

    # This is the default label that we apply to a card. If we find it then it's safe to assume that this was one we've created prior.
    card = cards.detect { |c| c.label.eql?("Brave Rewards") }

    # User's can change the label's on their cards so if we couldn't find it, we'll have to iterate until we find a card that matches are criteria
    # 1. Isn't the browser's wallet card
    # 2. Isn't a channel card
    cards.each do |c|
      break if card.present?

      # We don't want to accidentally set the Publisher's card used for auto contribute and referral deposits into a channel card
      # So we should check the address for the card and make sure it doesn't have a private address.
      next if existing_private_cards.include?(c.id)
      # Failsafe, for if the private card is missing
      next if has_private_address?(uphold_connection, c.id)

      card = c
    end

    # If the card doesn't exist so we should create it
    if card.blank?
      Rails.logger.info("Could not find existing card for #{uphold_connection.default_currency} - Creating a new card")
      card = uphold_connection.uphold_client.card.create(uphold_connection: uphold_connection)
    end

    # Finally let's update the address with the id of the card
    uphold_connection.update(address: card.id)
  end

  # Makes an HTTP Call to the Uphold card/:id/address endpoint to determine if the card has a private address
  #
  # Returns true if the card has a private address
  def has_private_address?(uphold_connection, card_id)
    addresses = uphold_connection.uphold_client.address.all(uphold_connection: uphold_connection, id: card_id)

    addresses.detect { |a| a.type == UpholdConnectionForChannel::NETWORK }.present?
  end
end
