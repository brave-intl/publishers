# typed: false
require "test_helper"

class BitflyerUpdateDepositIdService < ActiveSupport::TestCase
  include MockOauth2Responses

  describe Bitflyer::UpdateDepositIdService.name do
    let(:described_class) { Bitflyer::UpdateDepositIdService }
    let(:inst) { Bitflyer::UpdateDepositIdService.build }
    let(:publisher) { publishers(:bitflyer_pub) }
    let(:channel) { publisher.channels.first }
    let(:connection) { publisher.bitflyer_connection }

    describe "#build" do
      it "should return self" do
        assert_instance_of(described_class, inst)
      end
    end

    describe "#call" do
      before do
        channel.deposit_id = nil
      end

      describe "when connection is already failure" do
        before do
          connection.oauth_refresh_failed = true
        end

        test "it should BFailure" do
          assert_instance_of(BFailure, inst.call(channel))
        end
      end

      describe "when refresh" do
        let(:deposit_id) { "a value" }

        before do
          assert !channel.deposit_id
          mock_refresh_token_success(connection.class.oauth2_config.token_url)
          stub_request(:get, /api\/link\/v1\/account\/create-deposit-id/)
            .to_return(status: 200, body: {deposit_id: deposit_id}.to_json)
        end

        test "should return BSuccess" do
          assert_instance_of(BSuccess, inst.call(channel))
        end

        test "should update deposit id" do
          inst.call(channel)
          channel.reload
          assert channel.deposit_id == deposit_id
        end
      end

      describe "when !refresh" do
        before do
          mock_token_failure(connection.class.oauth2_config.token_url)
        end

        test "should BFailure " do
          assert_instance_of(BFailure, inst.call(channel))
        end
      end
    end
  end
end
