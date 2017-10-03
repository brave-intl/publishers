# An option for domain verification.

class PublisherDnsRecordGenerator < BaseService
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
    if !publisher.brave_publisher_id || !publisher.verification_token
      raise "Publisher doesn't have valid #brave_publisher_id and #verification_token"
    end
  end

  def can_perform?
    dns_record_value.size <= 255
  end

  def perform
    if !can_perform?
      raise "Can't generate a valid DNS record; it would be #{dns_record_value.size} character long which is over the TXT limit of 255."
    end
    dns_record_value
  end

  private

  def dns_record_value
    "brave-ledger-verification=#{publisher.verification_token}"
  end
end
