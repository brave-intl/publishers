class CreateUpholdChannelCardJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:, channel_id:)
    uphold_connection = UpholdConnection.find(uphold_connection_id)
    channel = Channel.find(channel_id)
    return unless uphold_connection&.is_member? && channel&.verified?

    unless uphold_connection.can_create_uphold_cards?
      Rails.logger.info("Could not create uphold card for channel #{uphold_connection.publisher_id}. Uphold Verified: #{uphold_connection.uphold_verified}")
      return
    end

    upfc = UpholdConnectionForChannel.find_by(
      uphold_connection: uphold_connection,
      currency: uphold_connection.default_currency,
      channel_identifier: channel.details.channel_identifier
    )

    if upfc.present?
      card_id = upfc.card_id
    else
      (card_id, upfc) = find_or_create_card(uphold_connection, channel)
    end

    # If the channel was deleted and then recreated we should update this to be the new channel id
    upfc.update(
      address: get_address(uphold_connection, card_id),
      channel_id: channel.id
    )
  end

  def find_or_create_card(uphold_connection, channel)
    card_label = "#{channel.type_display} - #{channel.details.publication_title} - Brave Rewards"

    # If a user transfers their channel then we should try not to create duplicate uphold cards
    cards = uphold_connection.uphold_client.card.where(uphold_connection: uphold_connection)
    card_id = cards.detect { |c| c.label.eql?(card_label) }&.id

    if card_id.blank?
      # If the card doesn't exist so we should create it
      card_id = uphold_connection.uphold_client.card.create(
        uphold_connection: uphold_connection,
        currency: uphold_connection.default_currency,
        label: card_label
      ).id
    end

    upfc = UpholdConnectionForChannel.create(
      uphold_connection: uphold_connection,
      channel: channel,
      card_id: card_id,
      currency: uphold_connection.default_currency,
      channel_identifier: channel.details.channel_identifier
    )

    [card_id, upfc]
  end

  def get_address(uphold_connection, card_id)
    address = addresses(uphold_connection, card_id).detect { |a| a.type == UpholdConnectionForChannel::NETWORK }
    address = address.formats.first.dig('value') if address.present?

    return address if address.present?

    uphold_connection.uphold_client.address.create(
      uphold_connection: uphold_connection,
      id: card_id,
      network: UpholdConnectionForChannel::NETWORK
    )
  end

  def addresses(uphold_connection, card_id)
    uphold_connection.uphold_client.address.all(
      uphold_connection: uphold_connection,
      id: card_id
    )
  rescue Faraday::ResourceNotFound
    []
  end
end
