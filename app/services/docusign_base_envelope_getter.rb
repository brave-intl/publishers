# Get requests are rate limited, 1 per 15m per unique envelope endpoint:
# https://docs.docusign.com/esign/guide/appendix/resource_limits.html
# https://www.docusign.com/developer-center/api-overview#go-live
# TODO: Use webhooks.
class DocusignBaseEnvelopeGetter < DocusignBaseService
  RATE_LIMIT_DELAY = 15.minutes

  attr_reader :last_gotten_at, :envelope_id

  def initialize(last_gotten_at:, envelope_id:)
    @last_gotten_at = last_gotten_at
    @envelope_id = envelope_id
  end

  def perform
    raise 'please define me'
  end

  private

  def can_perform?
    return true if !last_gotten_at
    time_elapsed = Time.zone.now - last_gotten_at
    time_elapsed > RATE_LIMIT_DELAY
  end

  def docusign_send(method_sym, **args)
    if !can_perform?
      raise DocusignBaseService::TooManyRequestsError.new("Can only get a unique envelope endpoint once per 15 minutes.")
    end
    super
  end
end
