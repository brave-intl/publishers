require "test_helper"

class SyncPromoRegistrationStatsJobTest < ActiveJob::TestCase
  describe "#perform" do
    let(:described_class) { Sync::PromoRegistrationStatsJob }

    describe "async" do
      describe "when false" do
        let(:promos) { [] }
        describe "when no promos" do
          it "should return empty array" do
            result = described_class.new.perform(PromoRegistration.where(id: promos))
            assert_instance_of(Array, result)
            assert_empty result
          end
        end

        describe "when promos" do
          it "should return empty array" do
            result = described_class.new.perform(PromoRegistration.pluck(:id))
            assert_instance_of(Array, result)
            refute_empty result
          end
        end
      end
    end
  end
end
