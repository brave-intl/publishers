require "test_helper"

class PromoRegistrationTest < ActiveSupport::TestCase
  PROMO_ID = "2018q1"
  REFERRAL_CODE = "BATS-123"

  test "promo registration doesn't need an associated channel_id if the kind is unattached" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: nil, promo_id: PROMO_ID, kind: "unattached", referral_code: REFERRAL_CODE)
    assert promo_registration.valid?
  end

  test "promo registration must have be kind channel if channel_id is present" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id,
                                               publisher_id: channel.publisher.id,
                                               promo_id: PROMO_ID,
                                               referral_code: REFERRAL_CODE)

    # verify validation fails if no kind is present
    refute promo_registration.valid?

    # verify validation passes if kind is set to channel
    promo_registration.kind = "channel"
    assert promo_registration.valid?
  end

  test "promo registration must have a channel_id if kind is channel" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(kind: "channel",
                                               publisher_id: channel.publisher.id,
                                               promo_id: PROMO_ID,
                                               referral_code: REFERRAL_CODE)

    # verify validation fails if no channel_id
    refute promo_registration.valid?

    # verify validation passes if kind is set to channel
    promo_registration.channel_id = channel.id
    assert promo_registration.valid?
  end

  test "promo registration must have a promo id" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id,
                                               promo_id: "",
                                               kind: "channel",
                                               publisher_id: channel.publisher.id,
                                               referral_code: REFERRAL_CODE)

    # verify validation fails if no associated promo_id
    assert !promo_registration.valid?

    # verify validation passses with associated promo_id
    promo_registration.promo_id = PROMO_ID
    assert promo_registration.valid?
  end

  test "promo registration must have a referral code" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id,
                                               kind: "channel",
                                               publisher_id: channel.publisher.id,
                                               promo_id: PROMO_ID,
                                               referral_code: nil)

    # verify validation fails is no associated referral code
    assert !promo_registration.valid?

    # verify validation passes with assoicated referral code
    promo_registration.referral_code = REFERRAL_CODE
    assert promo_registration.valid?
  end

  test "promo registration must have a unique referral code " do
    channel_verified = channels(:verified)
    channel_completed = channels(:completed)
    promo_registration = PromoRegistration.new(channel_id: channel_verified.id,
                                               promo_id: PROMO_ID,
                                               kind: "channel",
                                               publisher_id: channel_verified.publisher.id,
                                               referral_code: REFERRAL_CODE)
    promo_registration.save!

    # verify validation fails with non unique referall code
    promo_registration_invalid = PromoRegistration.new(channel_id: channel_completed.id,
                                                       promo_id: PROMO_ID,
                                                       kind: "channel",
                                                       publisher_id: channel_completed.publisher.id,
                                                       referral_code: REFERRAL_CODE)
    assert !promo_registration_invalid.valid?

    # verify validation passes with unique referral code
    promo_registration_invalid.referral_code = "BATS-321"
    assert promo_registration_invalid.valid?
  end

  # This might be better suited for ChannelTest
  test "channel can only have one promo registration" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id,
                                               promo_id: PROMO_ID,
                                               kind: "channel",
                                               publisher_id: channel.publisher.id,
                                               referral_code: REFERRAL_CODE)
    promo_registration.save!
    promo_registration_invalid = PromoRegistration.new(channel_id: channel.id,
                                                       promo_id: PROMO_ID,
                                                       kind: "channel",
                                                       publisher_id: channel.publisher.id,
                                                       referral_code: "BATS-321")
    promo_registration.save!

    # verify channel has only the first promo detail
    assert_equal channel.promo_registration, promo_registration
    assert_not_equal channel.promo_registration, promo_registration_invalid
  end

  test "if promo registration deleted, associated channel shouldn't be deleted" do
    channel = channels(:verified)
    promo_registration = PromoRegistration.new(channel_id: channel.id,
                                               promo_id: PROMO_ID,
                                               kind: "channel",
                                               publisher_id: channel.publisher.id,
                                               referral_code: REFERRAL_CODE)
    promo_registration.save!

    assert_equal channel.promo_registration, promo_registration

    promo_registration.delete
    assert Channel.exists?(channel.id)
  end

  test "aggregate_stats aggregates stats" do
    stats = [{"referral_code"=>"GHI789",
              "ymd"=>"2018-02-24",
              "retrievals"=>0,
              "first_runs"=>3,
              "finalized"=>0},
             {"referral_code"=>"GHI789",
              "ymd"=>"2018-02-25",
              "retrievals"=>0,
              "first_runs"=>3,
              "finalized"=>0},
             {"referral_code"=>"GHI789",
              "ymd"=>"2018-02-25",
              "retrievals"=>0,
              "first_runs"=>1,
              "finalized"=>1},
             {"referral_code"=>"GHI789",
              "ymd"=>"2018-02-25",
              "retrievals"=>0,
              "first_runs"=>1,
              "finalized"=>1}].to_json

    PromoRegistration.create!(referral_code: "GHI789", kind: "unattached", promo_id: PROMO_ID, stats: stats)

    promo_registration = PromoRegistration.find_by_referral_code("GHI789")

    assert_equal promo_registration.aggregate_stats["retrievals"], 0
    assert_equal promo_registration.aggregate_stats["first_runs"], 8
    assert_equal promo_registration.aggregate_stats["finalized"], 2
  end

  test "unattached scope returns only unattached promo registrations" do
    promo_registration = PromoRegistration.create!(referral_code: "ABC123", promo_id: PROMO_ID, kind: "unattached")
    channel = channels(:verified)
    PromoRegistration.create!(referral_code: "DEF456",
                              promo_id: PROMO_ID,
                              kind: "channel",
                              publisher_id: channel.publisher.id,
                              channel: channel)

    assert_equal PromoRegistration.unattached_only.count, 1
    assert_equal PromoRegistration.unattached_only.first, promo_registration
  end

  test "channel scope returns only channel owned promo registrations" do
    channel = channels(:verified)
    assert_equal PromoRegistration.channels_only.count, 2
    promo_registration = PromoRegistration.create!(referral_code: "DEF456",
                                                   promo_id: PROMO_ID,
                                                   kind: "channel",
                                                   publisher_id: channel.publisher.id,
                                                   channel: channel)
    PromoRegistration.create!(referral_code: "ABC123", promo_id: PROMO_ID, kind: "unattached")

    assert_equal PromoRegistration.channels_only.count, 3
    assert_equal PromoRegistration.channels_only.order("created_at").last, promo_registration
  end

  describe "promo enabled publishers" do
    let(:publisher) { publishers(:promo_enabled) }
    test "stats_by_date returns a summary version of stats grouped by dates and fills in dates" do
      # Ensure promo registrations with stats present has correct format
      publisher.promo_registrations.where(referral_code: "PRO123").first.update(stats: [{"referral_code"=>"PRO123",
                                                                                     "ymd"=>"2018-10-24",
                                                                                     "retrievals"=>1,
                                                                                     "first_runs"=>1,
                                                                                     "finalized"=>0},
                                                                                  {"referral_code"=>"PRO123",
                                                                                     "ymd"=>"2018-10-24",
                                                                                     "retrievals"=>1,
                                                                                     "first_runs"=>1,
                                                                                     "finalized"=>0}].to_json)
      result = PromoRegistration.find_by(referral_code: "PRO123").stats_by_date
      assert_equal "2018-10-24", result[0]['ymd']
      assert_equal 2, result[0]['retrievals']
      assert_equal 2, result[0]['first_runs']
      assert_equal 0, result[0]['finalized']
      assert_equal Date.today - Date.parse(result[0]['ymd']), result.length
    end
  end

  test "aggregate_stats class method aggregates stats for all of a publishers's promo registrations" do

    # Ensure promo registrations with default stats e.g. "{}" has correct format
    publisher = publishers(:promo_enabled)
    assert_equal PromoRegistration.aggregate_stats(publisher.promo_registrations), {PromoRegistration::RETRIEVALS => 0, PromoRegistration::FIRST_RUNS => 0, PromoRegistration::FINALIZED => 0}

    # Ensure promo registrations with empty stats e.g. "[]" has correct format
    publisher.promo_registrations.first.update(stats: [].to_json)
    assert_equal PromoRegistration.aggregate_stats(publisher.promo_registrations),
                 {PromoRegistration::RETRIEVALS => 0, PromoRegistration::FIRST_RUNS => 0, PromoRegistration::FINALIZED => 0}

    # Ensure promo registrations with stats present has correct format
    publisher.promo_registrations.where(referral_code: "PRO123").first.update(stats: [{"referral_code"=>"PRO123",
                                                                                   "ymd"=>"2018-10-24",
                                                                                   "retrievals"=>1,
                                                                                   "first_runs"=>1,
                                                                                   "finalized"=>0},
                                                                                {"referral_code"=>"PRO123",
                                                                                   "ymd"=>"2018-10-24",
                                                                                   "retrievals"=>1,
                                                                                   "first_runs"=>1,
                                                                                   "finalized"=>0}].to_json)

    publisher.reload
    assert_equal PromoRegistration.aggregate_stats(publisher.promo_registrations),
                 {PromoRegistration::RETRIEVALS => 2, PromoRegistration::FIRST_RUNS => 2, PromoRegistration::FINALIZED => 0}

    # Ensure we aggregate stats for multiple promo registrations
    publisher.promo_registrations.where(referral_code: "PRO456").first.update(stats: [{"referral_code"=>"PRO456",
                                                                                   "ymd"=>"2018-10-24",
                                                                                   "retrievals"=>3,
                                                                                   "first_runs"=>3,
                                                                                   "finalized"=>2},
                                                                                {"referral_code"=>"PRO456",
                                                                                   "ymd"=>"2018-10-24",
                                                                                   "retrievals"=>1,
                                                                                   "first_runs"=>1,
                                                                                   "finalized"=>1}].to_json)
    publisher.reload
    assert_equal PromoRegistration.aggregate_stats(publisher.promo_registrations),
                 {PromoRegistration::RETRIEVALS => 6, PromoRegistration::FIRST_RUNS => 6, PromoRegistration::FINALIZED => 3}
  end
end
