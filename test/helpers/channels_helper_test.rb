require 'test_helper'

class PublishersHelperTest < ActionView::TestCase
  test "channel_verification_status" do
    publisher = publishers(:default)
    channel = channels(:new_site)

    assert_equal 'incomplete', channel_verification_status(channel)

    channel.verification_started!
    assert_equal 'started', channel_verification_status(channel)

    channel.verification_failed!('something happened')
    assert_equal 'failed', channel_verification_status(channel)

    channel.verification_succeeded!
    assert_equal 'verified', channel_verification_status(channel)
  end

  test "channel_verification_details" do
    publisher = publishers(:default)
    channel = channels(:new_site)

    channel.verification_started!
    assert_equal t("helpers.channels.verification_in_progress"), channel_verification_details(channel)

    channel.verification_failed!
    assert_equal t("helpers.channels.generic_verification_failure"), channel_verification_details(channel)

    channel.verification_failed!('something happened')
    assert_equal 'something happened', channel_verification_details(channel)

    channel.verification_succeeded!
    assert_nil channel_verification_details(channel)
  end
end
