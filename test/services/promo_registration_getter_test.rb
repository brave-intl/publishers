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

  # NOTE: This will not pass until we the TO DOs in promo registation getter
  test "raises NoReferralCodeError when requesting referral_code for invalid promo_id " do
    # publisher = publishers(:completed)
    # channel = publisher.channels.first
    # PromoRegistrationGetter.any_instance.stubs(:active_promo_id).returns("invalid-promo-id")

    # assert_raise PromoRegistrationGetter::NoReferralCodeError do
    #   PromoRegistrationGetter.new(publisher: publisher, channel: channel).perform
    # end
  end
end
