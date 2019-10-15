# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:)
    uphold_connection = UpholdConnection.find(uphold_connection_id)

    unless uphold_connection.can_create_uphold_cards?
      Rails.logger.info("Could not create uphold card for publisher #{uphold_connection.publisher_id}. Uphold Verified: #{uphold_connection.uphold_verified}")
      return
    end

    return if address_already_exists?(uphold_connection)

    card = find_existing_card(uphold_connection)

    # If the card doesn't exist so we should create it
    if card.blank?
      Rails.logger.info("Could not find existing card for #{uphold_connection.default_currency} - Creating a new card")
      card = uphold_connection.uphold_client.card.create(uphold_connection: uphold_connection)
    end

    # Finally let's update the address with the id of the card
    uphold_connection.update(address: card.id)
  end

  # Iterates through the existing cards for an Uphold Account to find if we've already created a card
  #
  # Returns nil, or the card that was found
  def find_existing_card(uphold_connection)
    cards = uphold_connection.uphold_client.card.where(uphold_connection: uphold_connection)

    # This is the default label that we apply to a card. If we find it then it's safe to assume that this was one we've created prior.
    card = cards.detect { |c| c.label.eql?("Brave Rewards") }

    # User's can change the label's on their cards so if we couldn't find it, we'll have to iterate until we find a card.
    # We want to make sure isn't the browser's wallet card and isn't a channel card. We can do this by checking the private address
    cards.each do |c|
      break if card.present?
      next if has_private_address?(uphold_connection, c.id)

      card = c
    end

    card
  end

  # Checks to see if the address already exist and is in the right currency
  #
  # Returns true if the address is in the same currency as the existing connection address
  def address_already_exists?(uphold_connection)
    return if uphold_connection.address.blank?

    card = uphold_connection.uphold_client.card.find(
      uphold_connection: uphold_connection,
      id: uphold_connection.address
    )

    card&.currency.eql?(uphold_connection.default_currency)
  rescue Faraday::ResourceNotFound
  end

  # Makes an HTTP Call to the Uphold card/:id/address endpoint to determine if the card has a private address
  #
  # Returns true if the card has a private address
  def has_private_address?(uphold_connection, card_id)
    @existing_private_cards ||= UpholdConnectionForChannel.select(:card_id).where(uphold_connection: uphold_connection, uphold_id: uphold_connection.uphold_id).to_a
    return true if @existing_private_cards.include?(card_id)

    addresses = uphold_connection.uphold_client.address.all(uphold_connection: uphold_connection, id: card_id)

    addresses.detect { |a| a.type == UpholdConnectionForChannel::NETWORK }.present?
  end
end
