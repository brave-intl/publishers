class AddThreadsToPublisherNotes < ActiveRecord::Migration[5.2]
  def change
    add_reference :publisher_notes, :thread, type: :uuid, index: true
  end
end
