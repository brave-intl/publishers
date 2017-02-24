class AddFormFieldsS3KeyToPublisherLegalForms < ActiveRecord::Migration[5.0]
  def change
    change_table :publisher_legal_forms do |t|
      t.string :encrypted_form_fields_s3_key
      t.string :encrypted_form_fields_s3_key_iv
    end
  end
end
