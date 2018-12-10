require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  test "Membership test" do
    partner = partners(:default_partner)
    organization = Organization.create(name: "Brave", permissions: OrganizationPermission.new)
    membership = Membership.create(organization: organization, member: partner)

    assert_equal partner.membership, membership

    small_partner = partners(:small_partner)
    Membership.create(organization: organization, member: small_partner)

    assert_equal small_partner.membership.organization, organization
    assert_equal organization.memberships.count, 2

    Membership.create(organization: organization, member: small_partner)
    assert_equal organization.memberships.count, 2
  end
end
