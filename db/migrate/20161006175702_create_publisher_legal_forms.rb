class CreatePublisherLegalForms < ActiveRecord::Migration[5.0]
  def change
    create_table :publisher_legal_forms, id: :uuid do |t|
      t.references :publisher, type: :uuid, index: true, null: false
      t.string :form_type, null: :false
      t.string :docusign_envelope_id
      t.string :docusign_template_id
      t.string :status
      t.string :after_sign_token
      t.timestamp :after_sign_token_expires_at

      t.timestamps
      t.index :after_sign_token
    end
  end
end
