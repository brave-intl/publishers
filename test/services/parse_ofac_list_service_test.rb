# typed: false

require "test_helper"
require "minitest/mock"

class ParseOfacListServiceTest < ActiveSupport::TestCase
  test "records a successful run when the list comes back with addresses" do
    addresses = ["0x4f47bc496083c727c5fbe3ce9cdf2b0f6496270c", "18M8bJWMzWHDBMxoLqjHHAffdRy4SrzkfB"]

    ParseOfacListService.stub(:fetch_github_repo_top_level_files, {addresses: addresses}) do
      assert_equal addresses, ParseOfacListService.perform[:addresses]
    end

    assert_equal 1, ServiceRun.for_service(ParseOfacListService).count
  end

  test "does not record a run when the repo tree can't be read" do
    ParseOfacListService.stub(:fetch_github_repo_top_level_files, nil) do
      assert_nil ParseOfacListService.perform
    end

    assert_nil ServiceRun.last_success_at(ParseOfacListService)
  end

  test "does not record a run when the list comes back empty" do
    ParseOfacListService.stub(:fetch_github_repo_top_level_files, {addresses: []}) do
      assert_empty ParseOfacListService.perform[:addresses]
    end

    assert_nil ServiceRun.last_success_at(ParseOfacListService)
  end
end
