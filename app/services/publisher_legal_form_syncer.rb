class PublisherLegalFormSyncer
  attr_reader :publisher_legal_form

  def initialize(publisher_legal_form:)
    @publisher_legal_form = publisher_legal_form
  end

  def perform
    syncer = DocusignEnvelopeSyncer.new(
      envelope_id: publisher_legal_form.docusign_envelope_id
    )
    envelope_status = syncer.perform
    publisher_legal_form.status = envelope_status
    publisher_legal_form.save!
  end
end
