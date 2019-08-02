class CreateUpholdChannelCardJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:, channel_id:)
    uphold_connection = UpholdConnection.find(uphold_connection_id)
    channel = Channel.find(channel_id)
    return unless uphold_connection&.is_member? && channel&.verified?

    unless uphold_connection.can_create_uphold_cards?
      Rails.logger.info("Could not create uphold card for channel #{uphold_connection.publisher_id}. Uphold Verified: #{uphold_connection.uphold_verified}")
      SlackMessenger.new(message: "Could not create uphold card for the channel #{uphold_connection.publisher_id}.", channel: SlackMessenger::ALERTS).perform
      return
    end

    upfc = UpholdConnectionForChannel.where(
      uphold_connection: uphold_connection,
      currency: uphold_connection.default_currency,
      channel_identifier: channel.details.channel_identifier
    ).first

    if upfc.present?
      card = uphold_connection.uphold_client.card.find(uphold_connection: uphold_connection, id: upfc.card_id)
    else
      (card, upfc) = create_card(uphold_connection, channel)
    end

    # If the channel was deleted and then recreated we should update this to be the new channel id
    upfc.update(
      address: get_address(uphold_connection, card),
      channel_id: channel.id
    )
  end

  def create_card(uphold_connection, channel)
    card_label = "#{channel.type_display} - #{channel.details.publication_title} - Brave Rewards"

    # If the card doesn't exist so we should create it
    card = uphold_connection.uphold_client.card.create(
      uphold_connection: uphold_connection,
      currency: uphold_connection.default_currency,
      label: card_label
    )

    upfc = UpholdConnectionForChannel.new(
      uphold_connection: uphold_connection,
      channel: channel,
      card_id: card.id,
      currency: uphold_connection.default_currency,
      channel_identifier: channel.details.channel_identifier
    )

    [card, upfc]
  end

  def get_address(uphold_connection, card)
    address = card.address.dig(UpholdConnectionForChannel::NETWORK)

    return address if address.present?

    uphold_connection.uphold_client.card.create_address(
      uphold_connection: uphold_connection,
      card_id: card.id,
      network: UpholdConnectionForChannel::NETWORK
    )
  end
end
