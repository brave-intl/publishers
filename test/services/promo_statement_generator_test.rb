require "test_helper"

class PromoStatementGeneratorTest < ActiveJob::TestCase

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
    statement = PromoStatementGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-10-22".to_date,
                                end_date: "2018-10-22".to_date,
                                reporting_interval: "by_day").perform

    assert_equal statement["contents"], {"ABC123"=>{"2018-10-22".to_date=>{"retrievals"=>0, "first_runs"=>0, "finalized"=>0}}}
  end

  test "with no stats, generates an empty statement with cumulative reporting interval" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    statement = PromoStatementGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-10-22".to_date,
                                end_date: "2018-10-22".to_date,
                                reporting_interval: "cumulative").perform

    assert_equal statement["contents"], {"ABC123"=>{"2018-10-22".to_date=>{"retrievals"=>0, "first_runs"=>0, "finalized"=>0}}}
  end

  test "generates a statement with a 'by day' reporting interval" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    statement = PromoStatementGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-9-01".to_date,
                                end_date: "2018-10-29".to_date,
                                reporting_interval: "by_day").perform

    assert_equal statement["contents"].count, 1
    assert_equal statement["contents"]["ABC123"].count, 59

    checksums = {"retrievals" => 0, "first_runs" => 0, "finalized" => 0}
    statement["contents"]["ABC123"].each do |event|
      checksums["retrievals"] += event.second["retrievals"]
      checksums["first_runs"] += event.second["first_runs"]
      checksums["finalized"] += event.second["finalized"]
    end
    
    assert_equal checksums, {"retrievals" => 6, "first_runs" => 6, "finalized" => 6}
  end

  test "generates a statement with a 'by week' reporting interval" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    statement = PromoStatementGenerator.new(referral_codes: ["ABC123"],
                                start_date: "2018-9-01".to_date,
                                end_date: "2018-10-29".to_date,
                                reporting_interval: "by_week").perform

    assert_equal statement["contents"].count, 1
    assert_equal statement["contents"]["ABC123"].count, 10
    checksums = {"retrievals" => 0, "first_runs" => 0, "finalized" => 0}
    statement["contents"]["ABC123"].each do |event|
      checksums["retrievals"] += event.second["retrievals"]
      checksums["first_runs"] += event.second["first_runs"]
      checksums["finalized"] += event.second["finalized"]
    end

    assert_equal checksums, {"retrievals" => 6, "first_runs" => 6, "finalized" => 6}
  end

  test "generates a statement for two codes" do
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1", stats: STATS)
    statement = PromoStatementGenerator.new(referral_codes: ["ABC123", "DEF456"],
                                start_date: "2018-9-01".to_date,
                                end_date: "2018-10-29".to_date,
                                reporting_interval: "by_week").perform

    assert_equal statement["contents"].count, 2
    assert_equal statement["contents"]["ABC123"].count, 10
    assert_equal statement["contents"]["DEF456"].count, 10

    ["ABC123", "DEF456"].each do |code|
      checksums = {"retrievals" => 0, "first_runs" => 0, "finalized" => 0}
      statement["contents"][code].each do |event|
        checksums["retrievals"] += event.second["retrievals"]
        checksums["first_runs"] += event.second["first_runs"]
        checksums["finalized"] += event.second["finalized"]
      end
      assert_equal checksums, {"retrievals" => 6, "first_runs" => 6, "finalized" => 6}
    end
  end
end