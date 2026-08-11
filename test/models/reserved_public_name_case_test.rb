# typed: false

require "test_helper"

class ReservedPublicNameCaseTest < ActionDispatch::IntegrationTest
  test "a reserved public name cannot be taken back by changing the case" do
    channel = channels(:google_verified)
    reserved = reserved_public_names(:temporary)

    assert_equal "Slartybartfast", reserved.public_name
    assert reserved.created_at >= 1.year.ago, "the reservation must still be active"

    # same case, the reservation holds
    channel.public_name = reserved.public_name
    assert_not channel.valid?
    assert_includes channel.errors[:public_name], "already under use"

    # same name, one letter with another case — must also be blocked
    channel.public_name = reserved.public_name.downcase
    assert_not channel.valid?
    assert_includes channel.errors[:public_name], "already under use"

    # the public page downcase the query, so both cases resolve to the same channel
    # (query copied from Api::Nextv1::PublicChannelController#show)
    found = Channel.where(
      "LOWER(public_name) = :query OR LOWER(public_identifier) = :query",
      query: "Slartybartfast".downcase
    ).first
    assert_nil found
  end
end
