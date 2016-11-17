class PublisherLegalFormSyncer
  attr_reader :publisher_legal_form

  def initialize(publisher_legal_form:)
    @publisher_legal_form = publisher_legal_form
  end

  def perform
    sync_publisher_legal_form
    save_form_to_s3 if publisher_legal_form.completed?
  end

  def sync_publisher_legal_form
    syncer = DocusignEnvelopeGetter.new(
      envelope_gotten_at: publisher_legal_form.docusign_envelope_gotten_at,
      envelope_id: publisher_legal_form.docusign_envelope_id
    )
    envelope_status = syncer.perform!
    publisher_legal_form.status = envelope_status
    publisher_legal_form.docusign_envelope_gotten_at = Time.zone.now
    publisher_legal_form.save!
  end

  def save_form_to_s3
    s3_key = generate_s3_key
    s3_object = EncryptedS3Store.new.put_object(data: envelope_document_pdf, key: s3_key)
    publisher_legal_form.s3_key = s3_key
    publisher_legal_form.docusign_envelope_document_gotten_at = Time.zone.now
    publisher_legal_form.save!
  end

  private

  def envelope_document_pdf
    document_getter = DocusignEnvelopeDocumentGetter.new(
      last_gotten_at: publisher_legal_form.docusign_envelope_document_gotten_at,
      envelope_id: publisher_legal_form.docusign_envelope_id
    )
    document_getter.perform!
  end

  def generate_s3_key
    uuid = SecureRandom.uuid
    "publisher-legal-forms/#{uuid.first(2)}/#{uuid}.pdf.gpg"
  end
end
