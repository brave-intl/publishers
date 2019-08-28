require 'test_helper'
require 'webmock/minitest'
require 'minitest/spec'

class CreateUpholdChannelCardTest < ActiveJob::TestCase

  describe 'when a user creates uphold cards for the first time' do
    let(:uphold_connection) { uphold_connections(:details_connection) }
    let(:channel) { channels(:uphold_connected_details) }
    let(:card_id) { '123e4567-e89b-12d3-a456-426655440000' }

    subject { CreateUpholdChannelCardJob.perform_now(uphold_connection_id: uphold_connection.id, channel_id: channel.id) }

    before do
      stub_request(:get, /cards/).to_return(body: [].to_json)
      stub_request(:post, /cards/).to_return(body: {id: card_id}.to_json)
    end

    it 'does not have an existing uphold connection' do
      refute UpholdConnectionForChannel.find_by(
        uphold_connection: uphold_connection,
        currency: uphold_connection.default_currency,
        channel_identifier: channel.details.channel_identifier
      )
    end

    it 'creates an uphold card' do
      subject

      assert UpholdConnectionForChannel.find_by(
        uphold_connection: uphold_connection,
        currency: uphold_connection.default_currency,
        channel_identifier: channel.details.channel_identifier,
        uphold_id: uphold_connection.uphold_id,
        card_id: card_id
      )
    end
  end

  describe 'when a user calls create uphold cards again' do
    subject { CreateUpholdChannelCardJob.perform_now(uphold_connection_id: uphold_connection.id, channel_id: channel.id) }

    let(:uphold_connection) { uphold_connections(:details_connection) }
    let(:connection_for_channel) do
      UpholdConnectionForChannel.find_by(
        uphold_connection: uphold_connection,
        currency: uphold_connection.default_currency,
        channel_identifier: channel.details.channel_identifier
      )
    end


    describe 'when the currency stays the same' do
      let(:channel) { channels(:uphold_connected_twitch_details) }

      before do
        stub_request(:get, /card/).to_return(body: { id: connection_for_channel.card_id }.to_json)
        stub_request(:get, /addresses/).to_return(body: [{ type: UpholdConnectionForChannel::NETWORK, formats: [{ 'value' => 'new' }]}].to_json)
      end

      it 'has an existing uphold connection' do
        assert connection_for_channel
      end


      it 'updates the address' do
        previous_address = connection_for_channel.address

        subject

        connection_for_channel.address.wont_be_same_as(previous_address)
      end

    end
  end
end
