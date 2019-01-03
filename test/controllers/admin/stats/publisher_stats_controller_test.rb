require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  before do
    admin = publishers(:admin)
    sign_in admin
  end

  describe 'index' do
    before do
      get admin_stats_publisher_statistics_path
    end

    it 'assigns @all_publishers' do
      assert controller.instance_variable_get("@all_publishers")
    end

    it 'assigns @email_verified' do
      assert controller.instance_variable_get("@email_verified")
    end

    it 'assigns @email_verified_with_channel' do
      assert controller.instance_variable_get("@email_verified_with_channel")
    end

    it 'assigns @email_verified_with_verified_channel' do
      assert controller.instance_variable_get("@email_verified_with_channel")
    end

    describe 'when user requests CSV' do
      before do
        get admin_stats_publisher_statistics_path(format: 'csv')
      end

      it 'is a valid CSV file' do
        assert CSV.parse(response.body)
      end
    end
  end
end
