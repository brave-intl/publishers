require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "must have a name and cannot be taken" do
    organization = Organization.new(name: "Brave")
    assert organization.save
    refute organization.errors.present?

    organization = Organization.new(name: "Brave")
    refute organization.save
    assert organization.errors.present?

    organization = Organization.new
    refute organization.save
    assert organization.errors.present?
  end
end
