class AddNoteIdToPublisherStatusUpdate < ActiveRecord::Migration[5.2]
  def change
    add_reference :publisher_status_updates, :publisher_note, type: :uuid, index: true
  end
end
