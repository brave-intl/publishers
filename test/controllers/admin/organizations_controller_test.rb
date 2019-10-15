require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  before do
    admin = publishers(:admin)
    sign_in admin
    organization_permission = organization_permissions(:default_permission)
    @org_name = organization_permission.organization.name
    @org_id = organization_permissions(:default_permission).organization.id
  end

  describe "index" do
    it "assigns @organizations" do
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

  describe "show" do
    it "assigns @organization" do
      get admin_organization_path(@org_id)
      assert controller.instance_variable_get("@organization")
      assert controller.instance_variable_get("@organization").permissions
    end
  end

  describe "create" do
    let(:organization_name) { "Test Org" }
    let(:organization_params) do
      {
        organization: { name: organization_name },
        uphold: "1",
        referral_codes: "1",
        offline_reporting: "1"
      }
    end

    let(:subject) { post admin_organizations_path, params: organization_params }

    describe "when organization is valid" do
      before do
        subject
      end

      it "assigns organizations" do
        organization = controller.instance_variable_get("@organization")
        assert organization
      end

      it "assigns permissions correctly" do
        organization = controller.instance_variable_get("@organization")
        assert organization.permissions.uphold_wallet
        assert organization.permissions.referral_codes
        assert organization.permissions.offline_reporting
      end

      it "redirects to organization when saved" do
        organization = controller.instance_variable_get("@organization")
#        assert_redirected_to admin_organization_path(Organization.find_by(name: organization_name))
        assert_redirected_to controller: '/admin/organizations', action: :show, id: organization.id
      end
    end
  end

  describe "edit" do
    it "assigns @organization" do
      get edit_admin_organization_path(@org_id)
      assert controller.instance_variable_get("@organization")
      assert controller.instance_variable_get("@organization").permissions
    end
  end

  describe "update" do
    let(:organization_params) do
      {
        organization: { name: @org_name },
        uphold: "1",
        referral_codes: "1",
        offline_reporting: "1"
      }
    end

    let(:subject) do
      patch admin_organization_path(@org_id), params: organization_params
    end

    describe "when organization is valid" do
      it "updates the organization" do
        assert_equal Organization.find(@org_id).name, "The Guardian"

        @org_name = "Updated Name"
        subject
        assert_equal Organization.find(@org_id).name, "Updated Name"
      end

      it "sets the permissions correctly" do
        refute Organization.find(@org_id).permissions.offline_reporting

        subject

        assert Organization.find(@org_id).permissions.offline_reporting
      end
    end

    describe "when organization is invalid" do
      it "renders the edit page" do
        @org_name = ""
        subject
        assert_template :edit
      end
    end
  end
end
