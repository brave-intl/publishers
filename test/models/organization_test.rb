require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "does not have email and doesn't allow email" do
    organization = Organization.new(email: "hello@world.com")
    refute organization.save
    assert organization.errors.present?

    organization.email = nil
    assert organization.save
  end
end
