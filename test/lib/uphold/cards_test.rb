# typed: false
require "test_helper"

class UpholdCardsClientTest < ActiveSupport::TestCase
  include Uphold::Types
  include MockUpholdResponses

  let(:conn)  { uphold_connections(:verified_connection) }
  let(:described_class) { Uphold::Cards }
  let(:inst) { described_class.new("access token") }
  let(:id) { "some_id" }
  let(:payload) { {body: "some content"} }

  describe "#init" do
    it "should return self" do
      assert_instance_of(described_class, inst)
    end
  end

  describe "#list" do
    before do
      stub_list_cards
    end

    it "should return a list of cards" do
      result = inst.list

      result.each do |r|
        assert_instance_of(UpholdCard, r)
      end
    end
  end

  describe "#get" do
    let(:id) { "avalue" }

    before do
      stub_get_card(id: id)
    end

    it "should return an UpholdCard" do
      assert_instance_of(UpholdCard, inst.get(id))
    end
  end

  describe "#create" do
    let(:id) { "avalue" }
    let(:currency) { "BAT" }
    let(:label) { "label"} 
    let(:settings) { {starred: true} }

    before do
      stub_create_card(currency: currency, label: label, settings: settings)
    end

    it "should return an UpholdCard" do
      assert_instance_of(UpholdCard, inst.create(currency: currency, label: label, settings: settings))
    end
  end
end
