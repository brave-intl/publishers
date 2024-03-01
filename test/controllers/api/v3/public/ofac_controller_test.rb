# typed: false

require "test_helper"

class Api::V3::Public::OfacControllerTest < ActionDispatch::IntegrationTest
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

  test "/api/v3/public/channels/total_verified returns json count of verified channels" do
    ret_json = {"addresses" =>
                  ["0x4f47bc496083c727c5fbe3ce9cdf2b0f6496270c",
                    "18M8bJWMzWHDBMxoLqjHHAffdRy4SrzkfB",
                    "qpf2cphc5dkuclkqur7lhj2yuqq9pk3hmukle77vhq",
                    "qpusmp64rajses77x95g9ah825mtyyv74smwwkxhx3"]}
    ParseOfacListService.expects(:fetch_github_repo_top_level_files).returns(ret_json)

    get api_v3_public_ofac_banned_lists_path, headers: {"HTTP_AUTHORIZATION" => "Token token=fake_api_auth_token"}

    assert_equal(200, response.status)
    assert_equal(ret_json, JSON.parse(response.body))
  end
end
