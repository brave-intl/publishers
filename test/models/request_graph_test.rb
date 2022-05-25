require "test_helper"

class RequestGraphTest < ActiveSupport::TestCase
  describe "#ip_address" do
    describe "when !unique" do
      before do
        RequestGraph.create!(ip_address: "derp")
      end

      it "has a unique index constraint" do
         assert_raises(ActiveRecord::RecordNotUnique) { RequestGraph.create!(ip_address: 'derp') }
      end
    end
  end
end
