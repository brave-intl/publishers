require "test_helper"

class PromoCampaignTest < ActiveSupport::TestCase
  test "cannot create two campaigns with the same name" do
    campaign_1 = PromoCampaign.new(name: "Campaign 1")
    campaign_1.save!

    campaign_2 = PromoCampaign.new(name: "Campaign 1")
    refute campaign_2.valid?
  end
end