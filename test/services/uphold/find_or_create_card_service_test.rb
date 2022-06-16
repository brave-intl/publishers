# typed: false
require "test_helper"

class UpholdFindOrCreateCardService < ActiveSupport::TestCase
  include MockOauth2Responses
  include MockUpholdResponses
  include Oauth2::Responses
  include Uphold::Types

  describe Uphold::FindOrCreateCardService.name do
    let(:described_class) { Uphold::FindOrCreateCardService }
    let(:inst) { described_class.build }
    let(:connection) { uphold_connections(:google_connection) }

    describe "#build" do
      it "should return self" do
        assert_instance_of(described_class, inst)
      end
    end

    describe "#call" do
      describe "when connection is active" do
        describe "when card exists" do
          before do
            mock_refresh_token_success(connection.class.oauth2_config.token_url)
            stub_get_card(id: connection.address)
          end

          it "it should UpholdCard" do
            result = inst.call(connection)
            assert_instance_of(UpholdCard, result)
          end
        end

        describe "when !card exists" do
          describe "when some cards exist" do
            describe "when !matches label" do
              describe "when default_currency matches" do
                before do
                  mock_refresh_token_success(connection.class.oauth2_config.token_url)
                  connection.address = nil
                  connection.default_currency = "BAT"
                  connection.save!

                  # Brutal.
                  stub_list_cards(label: "derp", currency: "BAT")
                  stub_list_cards(label: "derp", currency: "BAT", stub: false).each do |card|
                    stub_list_card_addresses(id: card[:id])
                  end
                  stub_create_card
                end

                it "it should UpholdCard" do
                  result = inst.call(connection)
                  assert_instance_of(UpholdCard, result)
                end
              end

              describe "when default_currency !matches" do
                before do
                  mock_refresh_token_success(connection.class.oauth2_config.token_url)
                  connection.address = nil
                  connection.save!
                  stub_list_cards(label: "derp")
                  stub_create_card
                end

                it "it should UpholdCard" do
                  result = inst.call(connection)
                  assert_instance_of(UpholdCard, result)
                end
              end
            end

            describe "when matches label" do
              before do
                mock_refresh_token_success(connection.class.oauth2_config.token_url)
                connection.address = nil
                connection.default_currency = "BAT"
                connection.save!
                stub_list_cards(currency: "BAT")
              end

              it "it should UpholdCard" do
                result = inst.call(connection)
                assert_instance_of(UpholdCard, result)
              end
            end
          end

          describe "when no cards exist" do
            before do
              mock_refresh_token_success(connection.class.oauth2_config.token_url)
              connection.address = nil
              connection.save!

              stub_list_cards(empty: true)
              stub_create_card
            end

            it "it should UpholdCard" do
              result = inst.call(connection)
              assert_instance_of(UpholdCard, result)
            end
          end
        end
      end

      describe "when connection is already failure" do
        before do
          connection.update!(oauth_refresh_failed: true)
        end

        it "it should BFailure" do
          assert_instance_of(BFailure, inst.call(connection))
        end
      end
    end
  end
end
