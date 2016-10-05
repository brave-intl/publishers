# An option for domain verification.

class PublisherDnsRecordGenerator
  attr_reader :publisher

  def initialize(publisher)
    @publisher = publisher
    if !publisher.base_domain || !publisher.verification_token
      raise "Publisher doesn't have valid #base_domain and #verification_token"
    end
  end

  def can_perform?
    dns_record_value.size <= 255
  end

  def perform
    if !can_perform?
      raise "Can't generate a valid DNS record; it would be #{dns_record_value.size} which is TXT limit of >255."
    end
    dns_record_value
  end

  private

  def dns_record_value
    "This is a Brave Payments publisher verification; Domain: #{publisher.base_domain}; Token: #{publisher.verification_token}"
  end
end
