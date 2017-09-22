require "test_helper"

class BundlerAuditTest < ActiveSupport::TestCase
  test "no gem vulnerabilities" do
    skip 'TODO: Update Nokogiri because of CVE-2017-9050 for 1.7.2'

    require "bundler/audit/cli"
    Bundler::Audit::CLI.start(["update", "--quiet"])
    begin
      Bundler::Audit::CLI.start(["check", "--quiet"])
    rescue SystemExit
      assert false
    end
    assert true
  end
end
