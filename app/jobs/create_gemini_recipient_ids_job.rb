# Creates the Uphold Cards for a publisher
class CreateGeminiRecipientIdsJob < ApplicationJob
  queue_as :default

  def perform(gemini_connection_id:)
    gemini_connection = GeminiConnection.find(gemini_connection_id)
    # Users aren't able to create a recipient id if they are not fully verified
    if gemini_connection.payable?
      recipient = Gemini::RecipientId.find_or_create(token: gemini_connection.access_token)
      gemini_connection.update(recipient_id: recipient.recipient_id)
      gemini_connection.update_default_currency

      gemini_connection.publisher.channels.each do |channel|
        gemini_connection_for_channel = GeminiConnectionForChannel.where(
          gemini_connection: gemini_connection,
          currency: gemini_connection.default_currency,
          channel_identifier: channel.details.channel_identifier
        ).first_or_create(channel_id: channel.id)

        channel_recipient = Gemini::RecipientId.find_or_create(token: gemini_connection.access_token, label: channel.details.brave_publisher_id)

        # If the channel was deleted and then recreated we should update this to be the new channel id
        gemini_connection_for_channel.update(
          recipient_id: channel_recipient.recipient_id,
          # It's possible a channel can be removed, so this covers re-linking an existing gemini_connection_for_channel to the re-added channel.
          channel_id: channel.id,
        )
      end
    end
  end
end
