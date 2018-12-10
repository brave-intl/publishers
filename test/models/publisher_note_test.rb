require 'test_helper'

class PublisherNoteTest < ActiveSupport::TestCase
  test "can create a note and assign to publisher" do
    publisher = publishers(:created)
    admin = publishers(:admin)

    note = PublisherNote.new(note: "this is a note", publisher: publisher, created_by: admin)

    note.save!

    assert publisher.notes.first == note
  end

  test "when a publisher is destroyed, so are it's notes" do
    publisher = publishers(:created)
    admin = publishers(:admin)

    note = PublisherNote.new(note: "this is a note", publisher: publisher, created_by: admin)
    note.save!

    publisher.destroy!

    # ensure the note was destroyed
    assert PublisherNote.all.exclude? note
  end

  describe 'publisher status' do
    it 'is active when note is created after account' do
      assert_equal publisher_notes(:default).publisher_status.to_s, 'active'
    end

    it 'is suspended when note is created after publisher is suspended' do
      assert_equal publisher_notes(:comment_after_suspended).publisher_status.to_s, 'suspended'
    end
  end
end
