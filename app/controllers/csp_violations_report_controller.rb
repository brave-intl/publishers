# typed: ignore
class CspViolationsReportController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # Reports look something like:
    # {"document-uri"=>"https://localhost:3000/",
    #   "referrer"=>"",
    #   "violated-directive"=>"style-src-elem",
    #   "effective-directive"=>"style-src-elem",
    #   "original-policy"=>"default-src 'self' https:; font-src 'self' https: data:; img-src 'self' https: data:; object-src 'none'; script-src 'self' https: 'nonce-vF0eAyl4aPYfB1gs7173UQ=='; style-src 'self' https: 'nonce-vF0eAyl4aPYfB1gs7173UQ=='; report-uri /csp-violation-report",
    #   "disposition"=>"report",
    #   "blocked-uri"=>"inline",
    #   "line-number"=>4,
    #   "source-file"=>"https://localhost:3000/",
    #   "status-code"=>0,
    #   "script-sample"=>""}
    # We only care about the document-uri, blocked-uri, and directives for now
    report = JSON.parse(request.body.read)["csp-report"]
    sliced_report = report.slice("document-uri", "violated-directive", "effective-directive", "blocked-uri")
    begin
      CspViolationReport.create(report: sliced_report)
    rescue
      nil
    end
  end
end
