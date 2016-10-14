class AddDocusignEnvelopeGottenAtToPublisherLegalForms < ActiveRecord::Migration[5.0]
  def change
    change_table :publisher_legal_forms do |t|
      t.timestamp :docusign_envelope_gotten_at, after: :docusign_envelope_id
    end
  end
end
