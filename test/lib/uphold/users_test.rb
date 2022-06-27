# typed: false
require "test_helper"

class UpholdUsersClientTest < ActiveSupport::TestCase
  include Uphold::Types
  include MockUpholdResponses

  let(:conn) { uphold_connections(:verified_connection) }
  let(:described_class) { Uphold::Users }
  let(:inst) { described_class.new("access token") }

  describe "#init" do
    it "should return self" do
      assert_instance_of(described_class, inst)
    end
  end

  describe "#get" do
    let(:id) { "avalue" }

    before do
      stub_get_user
    end

    it "should return an UpholdUser" do
      assert_instance_of(UpholdUser, inst.get)
    end
  end

  describe "#get_capabilities" do
    let(:capability) { "deposits" }

    before do
      stub_get_user_capability(capability: capability)
    end

    it "should return an UpholdUserCapability" do
      assert_instance_of(UpholdUserCapability, inst.get_capability(capability))
    end
  end
end
