# Get envelope status from Docusign.
class DocusignEnvelopeGetter < DocusignBaseService
  RATE_LIMIT_DELAY = 15.minutes

  attr_reader :envelope_gotten_at, :envelope_id

  # NOTE: You can only run this method once per 15 minutes per envelope ID.
  # https://www.docusign.com/developer-center/api-overview#go-live
  # TODO: Use Webhooks
  def can_perform?
    return true if !envelope_gotten_at
    time_elapsed = Time.zone.now - envelope_gotten_at
    time_elapsed > RATE_LIMIT_DELAY
  end

  def initialize(envelope_gotten_at:, envelope_id:)
    @envelope_gotten_at = envelope_gotten_at
    @envelope_id = envelope_id
  end

  # Statuses:
  # https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/listStatusChanges/
  # NOTE: You can only run this method once per 15 minutes per envelope ID.
  # https://www.docusign.com/developer-center/api-overview#go-live
  # TODO: Use Webhooks
  def perform(raise_on_rate_limit: false)
    if !can_perform?
      return nil if !raise_on_rate_limit
      raise TooManyRequestsError.new("Can only get envelope status once per 15m per envelope ID.")
    end
    response = docusign_send(:get_envelope_status, envelope_id: envelope_id)
    response["status"]
  end

  def perform!
    perform(raise_on_rate_limit: true)
  end

  class TooManyRequestsError < RuntimeError
  end
end
