# Fetch envelope status from Docusign.
class DocusignEnvelopeSyncer < DocusignBaseService
  attr_reader :envelope_id

  def initialize(envelope_id:)
    @envelope_id = envelope_id
  end

  # Statuses:
  # https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/listStatusChanges/
  def perform
    response = docusign_send(:get_envelope_status, envelope_id: envelope_id)
    response["status"]
  end
end
