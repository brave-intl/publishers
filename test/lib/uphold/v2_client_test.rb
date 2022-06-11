# typed: false
require "test_helper"

class UpholdV2ClientTest < ActiveSupport::TestCase
  let(:conn)  { uphold_connections(:basic_connection) }
  let(:described_class) { Uphold::ConnectionClient }
  let(:inst) { described_class.new(conn: conn) }

  describe "#init" do
    it "should return self" do
      assert_instance_of(described_class, inst)
    end
  end

  describe "#init" do
    it "should return self" do
      assert_instance_of(Uphold::Cards, inst.cards)
    end
  end
end
