# typed: false

require "test_helper"

class RewardsTest < ActiveSupport::TestCase
  include Rewards::Types
  include MockRewardsResponses

  let(:described_class) { Rewards::Parameters }
  let(:inst) { described_class.new }

  describe "#init" do
    it "should return self" do
      assert_instance_of(described_class, inst)
    end
  end

  describe "#get" do
    before do
      stub_get_parameters
    end

    it "should return rewards data" do
      assert_instance_of(ParametersResponse, inst.get_parameters)
    end
  end
end
