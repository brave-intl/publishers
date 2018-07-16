require "test_helper"
require "shared/mailer_test_helper"

class Api::StatsControllerTest < ActionDispatch::IntegrationTest
  test 'does signups per day and handles blanks' do
    publishers(:verified).update(created_at: 6.days.ago)
    publishers(:completed).update(created_at: 1.day.ago)

    get "/api/stats/signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    resp = JSON.parse(response.body)
    assert_equal resp, [
      [6.days.ago.to_date.to_s, 1],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, 21]
    ]

    get "/api/stats/verified_signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    resp = JSON.parse(response.body)
    assert_equal resp, [
      [6.days.ago.to_date.to_s, 1],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, 20]
    ]
  end
end
