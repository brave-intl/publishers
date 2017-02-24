# Get envelope document signed PDF data
# Statuses:
# https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/listStatusChanges/
class DocusignEnvelopeDocumentGetter < DocusignBaseEnvelopeGetter
  def perform
    docusign_send(
      :get_document_from_envelope,
      document_id: 1,
      envelope_id: envelope_id,
      return_stream: true
    )
  end
end
