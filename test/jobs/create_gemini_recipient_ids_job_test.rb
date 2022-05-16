# typed: false
require "test_helper"
require "webmock/minitest"
require "minitest/spec"

class CreateGeminiRecipientIdsJobTest < ActiveJob::TestCase
  include MockGeminiResponses

  describe "when a user creates gemini recipient ids for the first time" do
    let(:gemini_connection) { gemini_connections(:gemini_in_japan_connection) }
    let(:channel) { channels(:gemini_in_japan_completed_website) }
    let(:recipient_id) { "abcd" }
    let(:recipient_id_channel) { "1234" }

    subject { CreateGeminiRecipientIdsJob.new.perform(gemini_connection.id) }

    before do
      gemini_connection.update(is_verified: true,
        status: "Active")
      mock_gemini_recipient_id!(recipient_id: recipient_id)
      mock_gemini_channels_recipient_id!(recipient_id: recipient_id_channel)
    end

    it "does not have an existing gemini connection" do
      refute GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier
      )
    end

    it "creates a gemini recipient id" do
      gemini_connection.update(recipient_id: nil)
      refute gemini_connection.recipient_id

      subject

      assert gemini_connection.reload.recipient_id == recipient_id

      assert GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        recipient_id: recipient_id_channel
      )
    end

    it "updates a gemini recipient id" do
      gemini_connection.update(recipient_id: recipient_id_channel)
      GeminiConnectionForChannel.create(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        channel: channel,
        recipient_id: recipient_id
      )

      assert gemini_connection.reload.recipient_id == recipient_id_channel
      assert GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        recipient_id: recipient_id
      )

      subject

      assert gemini_connection.reload.recipient_id == recipient_id
      assert GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        recipient_id: recipient_id_channel
      )
    end

    it "removes the updates the recipient ID status if there's a duplicate recipient_id" do
      subject

      second_connection = gemini_connections(:default_connection)
      second_connection.update(recipient_id: nil, is_verified: true,
        status: "Active")

      CreateGeminiRecipientIdsJob.new.perform(second_connection.id)

      assert second_connection.reload.recipient_id_duplicate? == true
      refute second_connection.reload.payable?
    end
  end
end
