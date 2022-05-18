# typed: false
# Creates the Gemini Recipient IDs for a publisher
class CreateGeminiRecipientIdsJob
  include Sidekiq::Worker
  # Retry on this creates the possibility of race conditions that accidentally break refreshs.
  sidekiq_options queue: :scheduler, retry: false

  def perform(gemini_connection_id)
    gemini_connection = GeminiConnection.find(gemini_connection_id)
    # Users aren't able to create a recipient id if they are not fully verified
    if gemini_connection.is_verified? && gemini_connection.status == "Active"
      recipient = Gemini::RecipientId.find_or_create(token: gemini_connection.access_token)

      if gemini_connection.update(recipient_id: recipient.recipient_id, recipient_id_status: "present")
        gemini_connection.publisher.channels.each do |channel|
          gemini_connection_for_channel = GeminiConnectionForChannel.where(
            gemini_connection: gemini_connection,
            channel_identifier: channel.details.channel_identifier
          ).find_or_initialize_by(channel_id: channel.id)

          channel_recipient = Gemini::RecipientId.find_or_create(token: gemini_connection.access_token, label: channel.id)

          # If the channel was deleted and then recreated we should update this to be the new channel id
          gemini_connection_for_channel.update(
            recipient_id: channel_recipient.recipient_id,
            # It's possible a channel can be removed, so this covers re-linking an existing gemini_connection_for_channel to the re-added channel.
            channel_id: channel.id
          )
        end
      else
        gemini_connection.update(recipient_id_status: "duplicate", recipient_id: nil)
      end
    end
  end
end
