class PublisherLegalFormSyncer
  attr_reader :legal_form_status_initial, :publisher_legal_form

  def initialize(publisher_legal_form:)
    @publisher_legal_form = publisher_legal_form
    @legal_form_status_initial = publisher_legal_form.status.dup
  end

  def legal_form_status_changed?
    legal_form_status_initial != publisher_legal_form.status
  end

  def perform
    sync_publisher_legal_form
    save_form_to_s3 if publisher_legal_form.completed?
    notify_slack if legal_form_status_changed?
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

  def s3_url
    PublisherLegalFormS3Getter.new(publisher_legal_form: publisher_legal_form).perform
  end

  def notify_slack
    human_form_type = I18n.t("publisher_legal_forms.complete_#{publisher_legal_form.form_type}")
    publisher = publisher_legal_form.publisher
    message = "*#{publisher}* #{publisher_legal_form.status} <#{s3_url}|#{human_form_type}>; id=#{publisher.id}"
    SlackMessenger.new(message: message).perform
  rescue Faraday::Error
    Rails.logger.warn("Couldn't #notify_slack in PublisherLegalFormSyncer.")
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
