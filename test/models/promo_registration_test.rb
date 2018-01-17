require "test_helper"

class PromoRegistrationTest < ActiveSupport::TestCase
  PROMO_ID = "2018q1"
  REFERRAL_CODE = "BATS-123"

  test "promo registration must have an associated channel" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: nil, promo_id: PROMO_ID, referral_code: REFERRAL_CODE)

    # verify validation fails if no associated channel
    assert !promo_registration.valid?

    # verify validation passes with associated channel
    promo_registration.channel_id = channel.id
    assert promo_registration.valid?
  end

  test "promo registration must have a promo id" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id, promo_id: "", referral_code: REFERRAL_CODE)

    # verify validation fails if no associated promo_id
    assert !promo_registration.valid?

    # verify validation passses with associated promo_id
    promo_registration.promo_id = PROMO_ID
    assert promo_registration.valid?
  end

  test "promo registration must have a referral code" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id, promo_id: PROMO_ID, referral_code: nil)

    # verify validation fails is no associated referral code
    assert !promo_registration.valid?

    # verify validation passes with assoicated referral code
    promo_registration.referral_code = REFERRAL_CODE
    assert promo_registration.valid?
  end

  test "promo registration must have a unique referral code " do
    channel_verified = channels(:verified)
    channel_completed = channels(:completed)
    promo_registration = PromoRegistration.new(channel_id: channel_verified.id, promo_id: PROMO_ID, referral_code: REFERRAL_CODE)
    promo_registration.save!

    # verify validation fails with non unique referall code
    promo_registration_invalid = PromoRegistration.new(channel_id: channel_completed.id, promo_id: PROMO_ID, referral_code: REFERRAL_CODE)
    assert !promo_registration_invalid.valid?

    # verify validation passes with unique referral code
    promo_registration_invalid.referral_code = "BATS-321"
    assert promo_registration_invalid.valid?
  end

  # This might be better suited for ChannelTest
  test "channel can only have one promo registration" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id, promo_id: PROMO_ID, referral_code: REFERRAL_CODE)
    promo_registration.save!
    promo_registration_invalid = PromoRegistration.new(channel_id: channel.id, promo_id: PROMO_ID, referral_code: "BATS-321")
    promo_registration.save!

    # verify channel has only the first promo detail
    assert_equal channel.promo_registration, promo_registration
    assert_not_equal channel.promo_registration, promo_registration_invalid
  end

  test "if promo registration deleted, associated channel shouldn't be deleted" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id, promo_id: PROMO_ID, referral_code: REFERRAL_CODE)
    promo_registration.save!

    assert_equal channel.promo_registration, promo_registration

    promo_registration.delete
    assert Channel.exists?(channel.id)
  end

  test "if promo registration deleted, associated publisher shouldn't be deleted" do
    # TO DO
  end
end