require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "must have a name and permission and cannot be taken" do
    permission = OrganizationPermission.new
    organization = Organization.new(name: "Brave", permissions: permission)
    assert organization.save
    refute organization.errors.present?

    organization = Organization.new(name: "Brave", permissions: permission)
    refute organization.save
    assert organization.errors.present?

    organization = Organization.new
    refute organization.save
    assert organization.errors[:name].present?
    assert organization.errors[:organization_permission].present?
  end
end
