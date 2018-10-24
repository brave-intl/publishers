require "test_helper"

class PromoReportGeneratorTest < ActiveJob::TestCase

  STATS = [{"ymd"=>"2018-09-01",
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1},
            {"ymd"=>"2018-09-03",
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1},
            {"ymd"=>"2018-09-08",
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1},
            {"ymd"=>"2018-10-15",
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1},
            {"ymd"=>"2018-10-20",
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1},
            {"ymd"=>"2018-10-29",
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1}].to_json

  test "with no stats, generates an empty statement by day" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    statement = PromoReportGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-10-22".to_date,
                                end_date: "2018-10-22".to_date,
                                reporting_interval: "by_day").perform

    assert_equal statement["contents"], {"ABC123"=>{"2018-10-22".to_date=>{PromoRegistration::RETRIEVALS=>0, PromoRegistration::FIRST_RUNS=>0, PromoRegistration::FINALIZED=>0}}}
  end

  test "with no stats, generates an empty statement with cumulative reporting interval" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    statement = PromoReportGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-10-22".to_date,
                                end_date: "2018-10-22".to_date,
                                reporting_interval: "cumulative").perform

    assert_equal statement["contents"], {"ABC123"=>{"2018-10-22".to_date=>{PromoRegistration::RETRIEVALS=>0, PromoRegistration::FIRST_RUNS=>0, PromoRegistration::FINALIZED=>0}}}
  end

  test "generates a statement with a 'by day' reporting interval" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    statement = PromoReportGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-9-01".to_date,
                                end_date: "2018-10-29".to_date,
                                reporting_interval: "by_day").perform

    assert_equal statement["contents"].count, 1
    assert_equal statement["contents"]["ABC123"].count, 59

    checksums = {PromoRegistration::RETRIEVALS => 0, PromoRegistration::FIRST_RUNS => 0, PromoRegistration::FINALIZED => 0}
    statement["contents"]["ABC123"].each do |event|
      checksums[PromoRegistration::RETRIEVALS] += event.second[PromoRegistration::RETRIEVALS]
      checksums[PromoRegistration::FIRST_RUNS] += event.second[PromoRegistration::FIRST_RUNS]
      checksums[PromoRegistration::FINALIZED] += event.second[PromoRegistration::FINALIZED]
    end
    
    assert_equal checksums, {PromoRegistration::RETRIEVALS => 6, PromoRegistration::FIRST_RUNS => 6, PromoRegistration::FINALIZED => 6}
  end

  test "generates a statement with a 'by week' reporting interval" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    statement = PromoReportGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-9-01".to_date,
                                end_date: "2018-10-29".to_date,
                                reporting_interval: "by_week").perform

    assert_equal statement["contents"].count, 1
    assert_equal statement["contents"]["ABC123"].count, 10
    checksums = {PromoRegistration::RETRIEVALS => 0, PromoRegistration::FIRST_RUNS => 0, PromoRegistration::FINALIZED => 0}
    statement["contents"]["ABC123"].each do |event|
      checksums[PromoRegistration::RETRIEVALS] += event.second[PromoRegistration::RETRIEVALS]
      checksums[PromoRegistration::FIRST_RUNS] += event.second[PromoRegistration::FIRST_RUNS]
      checksums[PromoRegistration::FINALIZED] += event.second[PromoRegistration::FINALIZED]
    end

    assert_equal checksums, {PromoRegistration::RETRIEVALS => 6, PromoRegistration::FIRST_RUNS => 6, PromoRegistration::FINALIZED => 6}
  end

  test "generates a statement for two codes" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    statement = PromoReportGenerator.new(referral_codes: ["ABC123", "DEF456"],
                                start_date: "2018-9-01".to_date,
                                end_date: "2018-10-29".to_date,
                                reporting_interval: "by_week").perform

    assert_equal statement["contents"].count, 2
    assert_equal statement["contents"]["ABC123"].count, 10
    assert_equal statement["contents"]["DEF456"].count, 10

    ["ABC123", "DEF456"].each do |code|
      checksums = {PromoRegistration::RETRIEVALS => 0, PromoRegistration::FIRST_RUNS => 0, PromoRegistration::FINALIZED => 0}
      statement["contents"][code].each do |event|
        checksums[PromoRegistration::RETRIEVALS] += event.second[PromoRegistration::RETRIEVALS]
        checksums[PromoRegistration::FIRST_RUNS] += event.second[PromoRegistration::FIRST_RUNS]
        checksums[PromoRegistration::FINALIZED] += event.second[PromoRegistration::FINALIZED]
      end
      assert_equal checksums, {PromoRegistration::RETRIEVALS => 6, PromoRegistration::FIRST_RUNS => 6, PromoRegistration::FINALIZED => 6}
    end
  end
end