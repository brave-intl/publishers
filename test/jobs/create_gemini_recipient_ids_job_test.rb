# typed: false

require "test_helper"
require "webmock/minitest"
require "minitest/spec"

class CreateGeminiRecipientIdsJobTest < ActiveJob::TestCase
  include MockGeminiResponses
  include MockRewardsResponses

  describe "when a user creates gemini recipient ids for the first time" do
    let(:gemini_connection) { gemini_connections(:top_referrer_gemini_connected) }
    let(:channel) { channels(:top_referrer_gemini_channel) }
    let(:recipient_id) { "abcd" }
    let(:recipient_id_channel) { "1234" }

    subject { CreateGeminiRecipientIdsJob.new.perform(gemini_connection.id) }

    before do
      stub_rewards_parameters
      gemini_connection.update(is_verified: true,
        status: "Active")
      mock_gemini_recipient_id!(recipient_id: recipient_id)
      mock_gemini_channels_recipient_id!(recipient_id: recipient_id_channel, label: channel.id)
    end

    it "creates a gemini recipient id for channels" do
      refute GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier
      )

      subject

      assert GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        recipient_id: recipient_id_channel
      )
    end

    it "updates a gemini recipient id for channel" do
      GeminiConnectionForChannel.create(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        channel: channel,
        recipient_id: recipient_id
      )

      assert GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        recipient_id: recipient_id
      )

      subject

      assert GeminiConnectionForChannel.find_by(
        gemini_connection: gemini_connection,
        channel_identifier: channel.details.channel_identifier,
        recipient_id: recipient_id_channel
      )
    end
  end
end
