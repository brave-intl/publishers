require "test_helper"
require "webmock/minitest"

class PromoRegistrationGetterTest < ActiveJob::TestCase
  test "raises PublisherChannelMismatchError when requesting referral_code for invalid publisher * channel combo" do
    publisher = publishers(:completed)
    channel = channels(:verified) # publisher does not own channel

    PromoRegistrationGetter.any_instance.stubs(:active_promo_id).returns("free-bats-2018q1")
    assert_raise PromoRegistrationGetter::PublisherChannelMismatchError do
      PromoRegistrationGetter.new(publisher: publisher, channel: channel).perform
    end
  end

  test "raises NoReferralCodeError when requesting referral_code for invalid promo_id " do
    publisher = publishers(:completed)
    channel = publisher.channels.first

    assert_raise PromoRegistrationGetter::NoReferralCodeError do
      PromoRegistrationGetter.new(publisher: publisher, channel: channel, promo_id: "invalid-promo-id").perform
    end
  end

  test "returns the promo code for a " do
    publisher = publishers(:completed)
    channel = publisher.channels.first

    # PromoRegistrationGetter.any_instance.stubs(:active_promo_id).returns("free-bats-2018q1")
    channel_referral_code = PromoRegistrationGetter.new(publisher: publisher, channel: channel).perform    

    assert_not_nil channel_referral_code
  end
end
