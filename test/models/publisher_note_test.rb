require 'test_helper'

class PublisherNoteTest < ActiveSupport::TestCase
  test "can create a note and assign to publisher" do
    publisher = publishers(:created)
    admin = publishers(:admin)

    note = PublisherNote.new(notes: "this is a note", publisher: publisher, created_by: admin.id)
    note.save!

    assert publisher.notes.first == note
  end

  test "when a publisher is destroyed, so are it's notes" do
    publisher = publishers(:created)
    admin = publishers(:admin)

    note = PublisherNote.new(notes: "this is a note", publisher: publisher, created_by: admin.id)
    note.save!

    publisher.destroy!

    # ensure the note was destroyed
    assert PublisherNote.all.exclude? note
  end
end
