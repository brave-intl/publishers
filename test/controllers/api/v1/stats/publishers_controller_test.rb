require "test_helper"
require "shared/mailer_test_helper"

class Api::V1::Stats::PublishersControllerTest < ActionDispatch::IntegrationTest
  test "does signups per day and handles blanks" do
    publishers(:verified).update(created_at: 6.days.ago)
    publishers(:completed).update(created_at: 1.day.ago)
    publishers(:uphold_connected).update(created_at: 6.days.ago)

    get "/api/v1/stats/publishers/signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status

    assert_equal [
      [6.days.ago.to_date.to_s, 2],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, Publisher.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day,
                                                role: Publisher::PUBLISHER)
                                          .count]
    ], JSON.parse(response.body)

    get "/api/v1/stats/publishers/email_verified_signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    assert_equal [
      [6.days.ago.to_date.to_s, 2],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, Publisher.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day,
                                                role: Publisher::PUBLISHER)
                                         .where.not(email: nil)
                                         .count]
    ], JSON.parse(response.body)

    get "/api/v1/stats/publishers/channel_and_email_verified_signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    assert_equal [
      [6.days.ago.to_date.to_s, 2],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 1],
      [0.days.ago.to_date.to_s, Publisher.distinct.joins(:channels)
                                         .where(created_at: Date.today.beginning_of_day..Date.today.end_of_day,
                                                role: Publisher::PUBLISHER)
                                         .where.not(email: nil)
                                         .where(channels: { verified: true })
                                         .count]
    ], JSON.parse(response.body)

    get "/api/v1/stats/publishers/channel_uphold_and_email_verified_signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    assert_equal [
      [6.days.ago.to_date.to_s, Publisher.distinct.joins(:channels).joins(:uphold_connection)
                                         .where(created_at: 6.days.ago.beginning_of_day..6.days.ago.end_of_day,
                                                'uphold_connections.uphold_verified': true,
                                                role: Publisher::PUBLISHER)
                                         .where.not(email: nil)
                                         .where(channels: { verified: true })
                                         .count],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 0],
      [0.days.ago.to_date.to_s, 0]
    ], JSON.parse(response.body)

    get "/api/v1/stats/publishers/channel_and_kyc_uphold_and_email_verified_signups_per_day", headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }

    assert_equal 200, response.status
    assert_equal [
      [6.days.ago.to_date.to_s, Publisher.distinct.joins(:channels).joins(:uphold_connection)
                                         .where(created_at: 6.days.ago.beginning_of_day..6.days.ago.end_of_day,
                                                'uphold_connections.uphold_verified': true, 'uphold_connections.is_member': true,
                                                role: Publisher::PUBLISHER)
                                         .where.not(email: nil)
                                         .where(channels: { verified: true })
                                         .count],
      [5.days.ago.to_date.to_s, 0],
      [4.days.ago.to_date.to_s, 0],
      [3.days.ago.to_date.to_s, 0],
      [2.days.ago.to_date.to_s, 0],
      [1.days.ago.to_date.to_s, 0],
      [0.days.ago.to_date.to_s, 0]
    ], JSON.parse(response.body)
  end

  test "totals endpoint has content" do
    # (Albert Wang): TODO, move this to private API
    get api_v1_stats_publishers_totals_path, headers: { "HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token" }
    assert JSON.parse(response.body)
    assert_response 200
  end
end
