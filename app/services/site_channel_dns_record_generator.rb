# An option for domain verification.

class SiteChannelDnsRecordGenerator < BaseService
  attr_reader :channel

  def initialize(channel:)
    @channel = channel
    if !channel.details.brave_publisher_id || !channel.details.verification_token
      raise "Channel doesn't have valid #brave_publisher_id and #verification_token"
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
    "brave-ledger-verification=#{channel.details.verification_token}"
  end
end
