require "test_helper"

class Promo::RegistrationStatsReportGeneratorTest < ActiveJob::TestCase
  before do
    @prev_promo_base_uri = Rails.application.secrets[:api_promo_base_uri]
  end

  after do
    Rails.application.secrets[:api_promo_base_uri] = @promo_base_uri
  end

  STATS = [
    {
      "referral_code" => "ABC123",
      "ymd" => "2018-11-01",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "ABC123",
      "ymd" => "2018-11-07",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "ABC123",
      "ymd" => "2018-11-14",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "ABC123",
      "ymd" => "2018-11-21",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "ABC123",
      "ymd" => "2018-11-28",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "ABC123",
      "ymd" => "2018-12-01",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "DEF456",
      "ymd" => "2018-11-01",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "DEF456",
      "ymd" => "2018-11-07",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "DEF456",
      "ymd" => "2018-11-14",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "DEF456",
      "ymd" => "2018-11-21",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "DEF456",
      "ymd" => "2018-11-28",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     },
    {
      "referral_code" => "DEF456",
      "ymd" => "2018-12-01",
      "retrievals" => 1,
      "first_runs" => 1,
      "finalized" => 1
     }
  ]

  GEO_STATS = []
  STATS.each do |stat|
    stat["country"] = "United States"
    GEO_STATS.push(stat)
    stat_mexico = stat.dup
    stat_mexico["country"] = "Mexico"
    GEO_STATS.push(stat_mexico)
  end

  test "generates report for running total without geo information" do
    Rails.application.secrets[:api_promo_base_uri] = "http://localhost:8194"
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1")

    stub_request(:get, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/statsByReferralCode?referral_code=ABC123&referral_code=DEF456").
      to_return(body: STATS.to_json)

    report = Promo::RegistrationStatsReportGenerator.new(referral_codes: ["ABC123","DEF456"],
                                                         start_date: "2018-11-01".to_date,
                                                         end_date: "2018-12-01".to_date,
                                                         reporting_interval: PromoRegistration::RUNNING_TOTAL,
                                                         is_geo: false).perform
    expected_report = {
      "contents" => {
        "ABC123" => {
          "2018-12-01".to_date => {
            "retrievals" => 6,
            "first_runs" => 6,
            "finalized" => 6
          }
        },
        "DEF456" => {
          "2018-12-01".to_date => {
            "retrievals" => 6,
            "first_runs" => 6,
            "finalized" => 6
          }
        }
      },
      "start_date" => "2018-11-01",
      "end_date" => "2018-12-01"
    }

    assert_equal expected_report, report
  end

  test "generates report for running total without geo information (2)" do # earlier end_date
    Rails.application.secrets[:api_promo_base_uri] = "http://localhost:8194"
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1")

    stub_request(:get, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/statsByReferralCode?referral_code=ABC123&referral_code=DEF456").
      to_return(body: STATS.to_json)
    report = Promo::RegistrationStatsReportGenerator.new(referral_codes: ["ABC123","DEF456"],
                                                         start_date: "2018-11-01".to_date,
                                                         end_date: "2018-11-28".to_date,
                                                         reporting_interval: PromoRegistration::RUNNING_TOTAL,
                                                         is_geo: false).perform
    expected_report = {
      "contents" => {
        "ABC123" => {
          "2018-11-28".to_date => {
            "retrievals" => 5,
            "first_runs" => 5,
            "finalized" => 5
          }
        },
        "DEF456" => {
          "2018-11-28".to_date => {
            "retrievals" => 5,
            "first_runs" => 5,
            "finalized" => 5
          }
        }
      },
      "start_date" => "2018-11-01",
      "end_date" => "2018-11-28"
    }

    assert_equal expected_report, report  end

  test "generates report for monthly without geo information" do
    Rails.application.secrets[:api_promo_base_uri] = "http://localhost:8194"
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1")

    stub_request(:get, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/statsByReferralCode?referral_code=ABC123&referral_code=DEF456").
      to_return(body: STATS.to_json)

    report = Promo::RegistrationStatsReportGenerator.new(referral_codes: ["ABC123","DEF456"],
                                                         start_date: "2018-11-01".to_date,
                                                         end_date: "2018-12-01".to_date,
                                                         reporting_interval: PromoRegistration::MONTHLY,
                                                         is_geo: false).perform
    expected_report = {
      "contents" => {
        "ABC123" => {
          "2018-11-01".to_date => {
            "retrievals" => 5,
            "first_runs" => 5,
            "finalized" => 5
          },
          "2018-12-01".to_date => {
            "retrievals" => 1,
            "first_runs" => 1,
            "finalized" => 1
          }
        },
        "DEF456" => {
          "2018-11-01".to_date => {
            "retrievals" => 5,
            "first_runs" => 5,
            "finalized" => 5
          },
          "2018-12-01".to_date => {
            "retrievals" => 1,
            "first_runs" => 1,
            "finalized" => 1
          }
        }
      },
      "start_date" => "2018-11-01",
      "end_date" => "2018-12-31"
    }

    assert_equal expected_report, report
  end

  test "generates report for weekly without geo information" do
    Rails.application.secrets[:api_promo_base_uri] = "http://localhost:8194"
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1")

    stub_request(:get, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/statsByReferralCode?referral_code=ABC123&referral_code=DEF456").
      to_return(body: STATS.to_json)

    report = Promo::RegistrationStatsReportGenerator.new(referral_codes: ["ABC123","DEF456"],
                                                         start_date: "2018-11-01".to_date,
                                                         end_date: "2018-11-07".to_date,
                                                         reporting_interval: PromoRegistration::WEEKLY,
                                                         is_geo: false).perform

    expected_report = {
      "contents"=> {
        "ABC123"=>
        {
          "2018-10-29".to_date => {
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1
          },
          "2018-11-05".to_date => {
             "retrievals"=>1,
             "first_runs"=>1,
             "finalized"=>1
           }
         },
         "DEF456"=> {
          "2018-10-29".to_date => {
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1
          },
         "2018-11-05".to_date => {
            "retrievals"=>1,
            "first_runs"=>1,
             "finalized"=>1
          }
        }
      },
     "start_date"=>"2018-10-29",
     "end_date"=>"2018-11-11"
    }
  end

  test "generates report for daily without geo information" do
    Rails.application.secrets[:api_promo_base_uri] = "http://localhost:8194"
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1")

    stub_request(:get, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/statsByReferralCode?referral_code=ABC123&referral_code=DEF456").
      to_return(body: STATS.to_json)

    report = Promo::RegistrationStatsReportGenerator.new(referral_codes: ["ABC123","DEF456"],
                                                         start_date: "2018-11-01".to_date,
                                                         end_date: "2018-11-02".to_date,
                                                         reporting_interval: PromoRegistration::DAILY,
                                                         is_geo: false).perform

    expected_contents = {
      "contents" => {
        "ABC123" => {
          "2018-11-01"=> {
            "retrievals"=>1,
            "first_runs"=>1,
            "finalized"=>1
          }
        },
        "DEF456" => {
          "2018-11-01" => {
             "retrievals"=>1,
             "first_runs"=>1,
             "finalized"=>1
           },
         },
       },
     "start_date"=>"2018-11-01",
     "end_date"=>"2018-11-02"
   }
  end

  test "generates report for running total with geo information" do
    Rails.application.secrets[:api_promo_base_uri] = "http://localhost:8194"
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1")

    stub_request(:get, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/geoStatsByReferralCode?referral_code=ABC123&referral_code=DEF456").
      to_return(body: GEO_STATS.to_json)

    report = Promo::RegistrationStatsReportGenerator.new(referral_codes: ["ABC123","DEF456"],
                                                         start_date: "2018-11-01".to_date,
                                                         end_date: "2018-12-01".to_date,
                                                         reporting_interval: PromoRegistration::RUNNING_TOTAL,
                                                         is_geo: true).perform
    expected_report = {
      "contents" => {
        "ABC123" => { 
          "2018-12-01".to_date => {
            "United States" => {
              "retrievals"=>6,
              "first_runs"=>6,
              "finalized"=>6
            },
            "Mexico"=> {
              "retrievals"=>6,
              "first_runs"=>6,
              "finalized"=>6
            }
          }
        },
        "DEF456" => {
          "2018-12-01".to_date => {
            "United States" => {
              "retrievals"=>6,
              "first_runs"=>6,
              "finalized"=>6
            },
            "Mexico" => {
              "retrievals"=>6,
              "first_runs"=>6,
              "finalized"=>6
            }
          }
        }
      },
      "start_date"=>"2018-11-01",
      "end_date"=>"2018-12-01"
    }
        
    assert_equal expected_report, report
  end

  test "generates report for weekly with geo information" do
    Rails.application.secrets[:api_promo_base_uri] = "http://localhost:8194"
    PromoRegistration.create!(referral_code: "ABC123", kind: "unattached", promo_id: "free-bats-2018q1")
    PromoRegistration.create!(referral_code: "DEF456", kind: "unattached", promo_id: "free-bats-2018q1")

    stub_request(:get, "#{Rails.application.secrets[:api_promo_base_uri]}/api/2/promo/geoStatsByReferralCode?referral_code=ABC123&referral_code=DEF456").
      to_return(body: GEO_STATS.to_json)

    report = Promo::RegistrationStatsReportGenerator.new(referral_codes: ["ABC123","DEF456"],
                                                         start_date: "2018-11-01".to_date,
                                                         end_date: "2018-11-14".to_date,
                                                         reporting_interval: PromoRegistration::WEEKLY,
                                                         is_geo: true).perform
    expected_report = {
      "contents"=>{"ABC123"=>
        {"2018-10-29".to_date=>
          {"United States"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1},
           "Mexico"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1}},
         "2018-11-05".to_date=>
          {"United States"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1},
           "Mexico"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1}},
         "2018-11-12".to_date=>
          {"United States"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1},
           "Mexico"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1}}},
       "DEF456"=>
        {"2018-10-29".to_date=>
          {"United States"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1},
           "Mexico"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1}},
         "2018-11-05".to_date=>
          {"United States"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1},
           "Mexico"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1}},
         "2018-11-12".to_date=>
          {"United States"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1},
           "Mexico"=>{"retrievals"=>1, "first_runs"=>1, "finalized"=>1}}}},
      "start_date"=>"2018-10-29",
      "end_date"=>"2018-11-18"
    }

    assert_equal expected_report, report
  end
end
