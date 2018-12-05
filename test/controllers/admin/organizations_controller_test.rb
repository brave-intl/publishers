require 'test_helper'
require "shared/mailer_test_helper"
require "webmock/minitest"

class Admin::PartnersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  before do
    admin = publishers(:admin)
    sign_in admin
  end

  describe 'index' do
    it 'assigns @organizations' do
      get admin_organizations_path
      assert controller.instance_variable_get("@organizations")
    end
  end

  describe "new" do
    it "assigns @organization" do
      get new_admin_organization_path
      assert controller.instance_variable_get("@organization")
      assert controller.instance_variable_get("@organization").permissions
    end
  end

  describe 'create' do
    let(:organization_params) do
      {
        organization: { name: 'org' },
        uphold: '1',
        referral_codes: '1',
        offline_reporting: '1'
      }
    end

    let(:subject) { post admin_organizations_path, params: organization_params }

    describe 'when organization is valid' do
      before do
        subject
      end

      it 'assigns organizations' do
        organization = controller.instance_variable_get("@organization")
        assert organization
      end

      it 'assigns permissions correctly' do
        organization = controller.instance_variable_get("@organization")
        assert organization.permissions.uphold_wallet
        assert organization.permissions.referral_codes
        assert organization.permissions.offline_reporting
      end

      it 'redirects to organization when saved' do
        organization = controller.instance_variable_get("@organization")
        assert_redirected_to admin_organization_path(organization.id)
      end
    end

    describe 'when test is invalid' do
      let(:organization_params) { { organization: { name: '' } } }

      before do
        subject
      end

      it 'renders new if invalid' do
        assert_template :new
      end
    end
  end
end
