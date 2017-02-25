# Get envelope recipients from Docusign.
# Includes status and
# Statuses:
# https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/listStatusChanges/
class DocusignEnvelopeRecipientsGetter < DocusignBaseEnvelopeGetter
  def perform
    docusign_send(
      :get_envelope_recipients,
      envelope_id: envelope_id,
      include_tabs: true
    )
  end
end
