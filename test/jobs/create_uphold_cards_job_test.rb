# typed: false
require "test_helper"
require "webmock/minitest"

# If you think this is difficult to reason about, it is.
class CreateUpholdCardsJobTest < ActiveJob::TestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper
  include EyeshadeHelper
  include MockUpholdResponses
  include MockOauth2Responses

  describe "#perform_now" do
    let(:connection) { uphold_connections(:google_connection) }

    # Woe to you if you try to use a value other than a valid UUID.
    # Address is DB value of uuid not string
    let(:id) { "024e51fc-5513-4d82-882c-9b22024280cc" }

    describe "card exists" do
      before do
        mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
        stub_get_card(id: id)
      end

      it "returns conn" do
        connection.update!(address: id)
        refute connection.address.nil?
        result = CreateUpholdCardsJob.perform_now(uphold_connection_id: connection.id)
        assert_equal result.address, id
      end
    end

    describe "card is not found" do
      # This is a case where somehow there is an address value on the connection
      # but no matching card.
      describe "!!address" do
        describe "when has cards with no matching currency" do
          let(:id) { "224e51fc-5513-4d82-882c-9b22024280cc" }
          before do
            mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
            stub_list_cards
            stub_get_card(id: id, http_status: 404)
            stub_create_card(id: id)
          end

          it "returns conn" do
            connection.update!(address: id)
            refute connection.address.nil?
            result = CreateUpholdCardsJob.perform_now(uphold_connection_id: connection.id)
            assert_equal result.address, id
          end
        end

        describe "when has matching currency card with different address" do
          before do
            mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
            stub_list_cards(currency: connection.default_currency)
            stub_get_card(http_status: 404)
          end

          it "returns conn" do
            connection.update!(address: id)
            refute connection.address.nil?
            result = CreateUpholdCardsJob.perform_now(uphold_connection_id: connection.id)
            assert_equal result.address, id
          end
        end
      end
      describe "!address" do
        describe "when has no cards" do
          let(:id) { "224e51fc-5513-4d82-882c-9b22024280cc" }
          before do
            mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
            stub_list_cards(empty: true)
            stub_get_card(id: id, http_status: 404)
            stub_create_card(id: id)
          end

          it "returns conn" do
            connection.update!(address: id)
            refute connection.address.nil?
            result = CreateUpholdCardsJob.perform_now(uphold_connection_id: connection.id)
            assert_equal result.address, id
          end
        end

        describe "when has cards with no matching currency" do
          let(:id) { "224e51fc-5513-4d82-882c-9b22024280cc" }
          before do
            mock_refresh_token_success(UpholdConnection.oauth2_config.token_url)
            stub_list_cards
            stub_get_card(id: id, http_status: 404)
            stub_create_card(id: id)
          end

          it "returns conn" do
            connection.update!(address: id)
            refute connection.address.nil?
            result = CreateUpholdCardsJob.perform_now(uphold_connection_id: connection.id)
            assert_equal result.address, id
          end
        end
      end
    end
  end
end
