require "test_helper"

class PartnerTest < ActiveSupport::TestCase
  test "All partners will have role of Partner" do
    p = Partner.new(email: 'test@example.com')
    assert p.partner?
  end
end
