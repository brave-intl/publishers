# typed: false

require "test_helper"
require "minitest/mock"

class ParseProhibitedListServiceTest < ActiveSupport::TestCase
  test "records a successful run when the list comes back with addresses" do
    addresses = ["0x4f47bc496083c727c5fbe3ce9cdf2b0f6496270c", "18M8bJWMzWHDBMxoLqjHHAffdRy4SrzkfB"]

    ParseProhibitedListService.stub(:fetch_s3_addresses, {addresses: addresses}) do
      assert_equal addresses, ParseProhibitedListService.perform[:addresses]
    end

    assert_equal 1, ServiceRun.for_service(ParseProhibitedListService).count
  end

  test "does not record a run when the bucket can't be read" do
    ParseProhibitedListService.stub(:fetch_s3_addresses, nil) do
      assert_nil ParseProhibitedListService.perform
    end

    assert_nil ServiceRun.last_success_at(ParseProhibitedListService)
  end

  test "does not record a run when the list comes back empty" do
    ParseProhibitedListService.stub(:fetch_s3_addresses, {addresses: []}) do
      assert_empty ParseProhibitedListService.perform[:addresses]
    end

    assert_nil ServiceRun.last_success_at(ParseProhibitedListService)
  end

  test "decodes addresses from bucket object keys across pages" do
    eth = "0x4f47bc496083c727c5fbe3ce9cdf2b0f6496270c"
    btc = "18M8bJWMzWHDBMxoLqjHHAffdRy4SrzkfB"
    encode = ->(addr) { Base64.urlsafe_encode64(addr).gsub(/^=+|=+/, "") }

    client = Aws::S3::Client.new(region: "us-west-2", stub_responses: true)
    client.stub_responses(:list_objects_v2, [
      {contents: [{key: encode.call(eth)}, {key: "README.md"}], is_truncated: true, next_continuation_token: "next"},
      {contents: [{key: encode.call(btc)}, {key: encode.call(eth)}], is_truncated: false}
    ])

    assert_equal [eth, btc], ParseProhibitedListService.fetch_s3_addresses(client: client, bucket: "test-bucket")[:addresses]
  end
end
