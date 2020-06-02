require 'test_helper'

class PublishersHelperTest < ActionView::TestCase
  test "channel_verification_status" do
    channel = channels(:new_site)

    assert_equal 'incomplete', channel_verification_status(channel)

    channel.verification_failed!('token_not_found_public_file')
    assert_equal 'failed', channel_verification_status(channel)

    SiteChannelDomainSetter.new(channel_details: channel.details).perform

    channel.verification_succeeded!(false)
    assert_equal 'verified', channel_verification_status(channel)
  end

  test "failed_verification_details" do
    channel = channels(:new_site)

    channel.verification_failed!
    assert_equal t("helpers.channels.verification_failure_explanation.generic"), failed_verification_details(channel)

    channel.verification_failed!("domain_not_found")
    assert_equal t("helpers.channels.verification_failure_explanation.domain_not_found"), failed_verification_details(channel)

    channel.verification_failed!("connection_failed")
    assert_equal t("helpers.channels.verification_failure_explanation.connection_failed", domain: channel.details.brave_publisher_id),
     failed_verification_details(channel)

    channel.verification_failed!("too_many_redirects")
    assert_equal t("helpers.channels.verification_failure_explanation.too_many_redirects"), failed_verification_details(channel)

    channel.verification_failed!("no_txt_records")
    assert_equal t("helpers.channels.verification_failure_explanation.no_txt_records"), failed_verification_details(channel)

    channel.verification_failed!("token_incorrect_dns")
    assert_equal t("helpers.channels.verification_failure_explanation.token_incorrect_dns"), failed_verification_details(channel)

    channel.verification_failed!("token_not_found_dns")
    assert_equal t("helpers.channels.verification_failure_explanation.token_not_found_dns"), failed_verification_details(channel)

    channel.verification_failed!("token_not_found_public_file")
    assert_equal t("helpers.channels.verification_failure_explanation.token_not_found_public_file"), failed_verification_details(channel)

    channel.verification_failed!("no_https")
    assert_equal t("helpers.channels.verification_failure_explanation.no_https"), failed_verification_details(channel)

    SiteChannelDomainSetter.new(channel_details: channel.details).perform
    channel.verification_succeeded!(false)
    assert_equal t("helpers.channels.verification_failure_explanation.generic"), failed_verification_details(channel)
  end
end
