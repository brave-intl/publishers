require 'test_helper'
require "webmock/minitest"

class Admin::PromoCampaignsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "#creates a promo campaign" do
    admin = publishers(:admin)
    sign_in admin
    post(admin_promo_campaigns_path, params: {campaign_name: "Campaign 1"})
    assert_equal PromoCampaign.order("created_at").last.name, "Campaign 1"
  end
end