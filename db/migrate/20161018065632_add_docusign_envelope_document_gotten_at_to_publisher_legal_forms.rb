class AddDocusignEnvelopeDocumentGottenAtToPublisherLegalForms < ActiveRecord::Migration[5.0]
  def change
    change_table :publisher_legal_forms do |t|
      t.timestamp :docusign_envelope_document_gotten_at, before: :docusign_envelope_gotten_at
    end
  end
end
