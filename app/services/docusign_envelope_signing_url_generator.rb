# Docusign envelopes are signable things
class DocusignEnvelopeSigningUrlGenerator < DocusignBaseService
  attr_reader :email, :envelope_id, :name, :return_url

  # The API supports multiple signers. For now we'll just support one.
  def initialize(email:, envelope_id:, name:, return_url:)
    @email = email
    @envelope_id = envelope_id
    @name = name
    @return_url = return_url
  end

  def perform
    response = docusign_send(
      :get_recipient_view,
      envelope_id: envelope_id,
      name: name,
      email: email,
      return_url: return_url
    )
    response["url"]
  end
end
