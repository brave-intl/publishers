# Get all contact emails from for a domain
class GetWhoisEmailsForDomain < BaseService
  def initialize(domain)
    @domain = domain
  end

  def perform    
    require "whois"
    require "whois-parser"
    record = Whois.whois(@domain)
    record.parser.contacts
  end
end