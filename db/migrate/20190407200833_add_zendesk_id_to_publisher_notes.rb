class AddZendeskIdToPublisherNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :publisher_notes, :zendesk_ticket_id, :bigint
    add_column :publisher_notes, :zendesk_comment_id, :bigint
    add_index :publisher_notes, [:zendesk_ticket_id, :zendesk_comment_id], unique: true, name: "index_publisher_notes_zendesk_ids"
  end
end
