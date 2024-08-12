# typed: false

require "test_helper"
require "bundler/audit/database"
require "bundler/audit/scanner"

class BundlerAuditTest < ActiveSupport::TestCase
  test "no gem vulnerabilities" do
    Bundler::Audit::Database.update!(quiet: true)
    vulnerabilities = []
    scanner = Bundler::Audit::Scanner.new
    scanner.scan(ignore: ["CVE-2015-9284", "CVE-2024-6531"]) do |result|
      vulnerabilities << "#{result.gem.name} #{result.gem.version} CVE #{result.advisory.cve}"
    end

    if vulnerabilities.present?
      puts vulnerabilities
      assert false
    end

    assert true
  end
end
