require "test_helper"

class SyncChannelPromoRegistrationStatsJobTest < ActiveJob::TestCase
  describe "#perform" do
    let(:described_class) { Sync::ChannelPromoRegistrationsStatsJob }

    describe "async" do
      describe "when promos" do
        let(:promos) { Promos.pluck(:id) }

        it "should return a count" do
          result = described_class.new.perform(0, 1000, false)
          assert_instance_of(Integer, result)
          assert result
        end

        it "should wait" do
          result = described_class.new.perform(0.01, 1000, false)
          assert_instance_of(Integer, result)
          assert result
        end

        it "should async" do
          result = described_class.new.perform(0, 1000, true)
          assert_instance_of(Integer, result)
          assert result
        end
      end
    end
  end
end
