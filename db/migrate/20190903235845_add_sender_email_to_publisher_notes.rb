class AddSenderEmailToPublisherNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :publisher_notes, :zendesk_to_email, :string, index: true
    add_column :publisher_notes, :zendesk_from_email, :string, index: true
  end
end
