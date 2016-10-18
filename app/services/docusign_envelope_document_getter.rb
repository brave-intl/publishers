# Get envelope document signed PDF data
class DocusignEnvelopeDocumentGetter < DocusignBaseService
  RATE_LIMIT_DELAY = 15.minutes

  attr_reader :last_gotten_at, :envelope_id

  # NOTE: You can only run this method once per 15 minutes per envelope ID.
  # https://www.docusign.com/developer-center/api-overview#go-live
  # TODO: Use Webhooks
  def can_perform?
    return true if !last_gotten_at
    time_elapsed = Time.zone.now - last_gotten_at
    time_elapsed > RATE_LIMIT_DELAY
  end

  def initialize(last_gotten_at:, envelope_id:)
    @last_gotten_at = last_gotten_at
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
      raise DocusignBaseService::TooManyRequestsError.new("Can only get envelope status once per 15m per envelope ID.")
    end
    docusign_send(
      :get_document_from_envelope,
      document_id: 1,
      envelope_id: envelope_id,
      return_stream: true
    )
  end

  def perform!
    perform(raise_on_rate_limit: true)
  end
end
