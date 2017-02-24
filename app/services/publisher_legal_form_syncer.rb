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
    getter = DocusignEnvelopeRecipientsGetter.new(
      last_gotten_at: publisher_legal_form.docusign_envelope_gotten_at,
      envelope_id: publisher_legal_form.docusign_envelope_id
    )
    result = getter.perform
    signer = result['signers'][0]
    sync_publisher_legal_form_status(status: signer['status'])
    if publisher_legal_form.completed?
      save_form_to_s3
      save_form_fields_to_s3(signer: signer)
    end
    notify_slack if legal_form_status_changed?
  end

  def sync_publisher_legal_form_status(status:)
    publisher_legal_form.status = status
    publisher_legal_form.docusign_envelope_gotten_at = Time.zone.now
    publisher_legal_form.save!
  end

  def save_form_to_s3
    s3_key = "#{base_s3_key}.pdf.gpg"
    s3_object = EncryptedS3Store.new.put_object(data: envelope_document_pdf, key: s3_key)
    publisher_legal_form.s3_key = s3_key
    publisher_legal_form.docusign_envelope_document_gotten_at = Time.zone.now
    publisher_legal_form.save!
  end

  def save_form_fields_to_s3(signer:)
    s3_key = "#{base_s3_key}.json.gpg"
    fields = DocusignEnvelopeFieldsGetter.new(signer: signer).perform
    data = JSON.pretty_generate(fields)
    s3_object = EncryptedS3Store.new.put_object(data: data, key: s3_key)
    publisher_legal_form.form_fields_s3_key = s3_key
    publisher_legal_form.save!
  end

  def s3_getter
    @s3_getter ||= PublisherLegalFormS3Getter.new(publisher_legal_form: publisher_legal_form)
  end

  def form_s3_url
    s3_getter.get_form_s3_url
  end

  def form_fields_s3_url
    s3_getter.get_form_fields_s3_url
  end

  def notify_slack
    human_form_type = I18n.t("publisher_legal_forms.complete_#{publisher_legal_form.form_type}")
    publisher = publisher_legal_form.publisher
    message = "*#{publisher}* #{publisher_legal_form.status} <#{form_s3_url}|#{human_form_type}> (<#{form_fields_s3_url}|json>); id=#{publisher.id}"
    SlackMessenger.new(message: message).perform
  rescue Faraday::Error
    Rails.logger.warn("Couldn't #notify_slack in PublisherLegalFormSyncer.")
  end

  private

  def envelope_document_pdf
    getter = DocusignEnvelopeDocumentGetter.new(
      last_gotten_at: publisher_legal_form.docusign_envelope_document_gotten_at,
      envelope_id: publisher_legal_form.docusign_envelope_id
    )
    getter.perform
  end

  def base_s3_key
    @base_s3_key ||= begin
      uuid = SecureRandom.uuid
      "publisher-legal-forms/#{uuid.first(2)}/#{uuid}"
    end
  end
end
