require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Admin
  class PublisherNotesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    before do
      admin = publishers(:admin)
      sign_in admin
    end

    describe '#create' do
      describe 'when the user comments on a publisher' do
        let(:note_params) { { publisher_note: { note: "this is a new note" } } }
        let(:subject) { post admin_publisher_publisher_notes_path(publishers(:verified).id), params: note_params }

        before do
          subject
        end

        it 'creates a top level note' do
          assert_equal publishers(:verified).notes.count, 1
          assert_equal publishers(:verified).notes.first.note, "this is a new note"
        end

        it 'redirects to the publisher page' do
          assert_redirected_to admin_publisher_path(publishers(:verified))
        end
      end

      describe 'when the note contains a mention' do
        let(:note_params) { { publisher_note: { note: "@hello testing this" } } }
        let(:subject) { post admin_publisher_publisher_notes_path(publishers(:verified).id), params: note_params }

        it 'enqueued the email' do
          assert_enqueued_emails(1) { subject }
        end

        it 'sends to the user' do
          perform_enqueued_jobs { subject }

          email = ActionMailer::Base.deliveries.find do |message|
            message.to.first == "hello@brave.com"
          end

          refute_nil email
        end
      end

      describe 'when the note is being replied' do
        describe 'it replies to admins' do
          let(:note_params) do
            {
              publisher_note: {
                note: "reply note",
                thread_id: publisher_notes(:note).id
              }
            }
          end

          let(:subject) { post admin_publisher_publisher_notes_path(publishers(:verified).id), params: note_params }

          it 'emails the user who is being replied to' do
            perform_enqueued_jobs { subject }

            email = ActionMailer::Base.deliveries.find do |message|
              message.to.first == publisher_notes(:note).created_by.email
            end

            refute_nil email
          end
        end

        describe 'it does not send an email to non-administrators' do
          let(:note_params) do
            {
              publisher_note: {
                note: "reply note",
                thread_id: publisher_notes(:non_admin_note).id
              }
            }
          end

          let(:subject) { post admin_publisher_publisher_notes_path(publishers(:verified).id), params: note_params }

          it 'emails the user who is being replied to' do
            perform_enqueued_jobs { subject }

            email = ActionMailer::Base.deliveries.find do |message|
              message.to.first == publisher_notes(:non_admin_note).created_by.email
            end

            assert_nil email
          end
        end
      end

      describe 'when there is an error' do
        let(:note_params) do
          {
            publisher_note: {
              note: "",
              thread_id: publisher_notes(:note).id
            }
          }
        end

        let(:subject) { post admin_publisher_publisher_notes_path(publishers(:verified).id), params: note_params }

        before do
          subject
        end

        it 'does not create a note' do
          assert_equal flash[:alert], "Note can't be blank"
        end

        it 'redirects to the publisher page' do
          assert_redirected_to admin_publisher_path(publishers(:verified))
        end
      end
    end

    describe '#update' do
      describe 'when the admin is updating' do
        let(:subject) do
          patch admin_publisher_publisher_note_path(
            id: publisher_notes(:admin_note).id,
            publisher_id: publishers(:verified).id
          ), params: note_params
        end

        describe 'when the note contains a mention' do
          let(:note_params) do
            { publisher_note: { note: "@hello test" } }
          end

          it 'emails the users' do
            perform_enqueued_jobs { subject }

            email = ActionMailer::Base.deliveries.find do |message|
              message.to.first == "hello@brave.com"
            end

            refute_nil email
          end

          it 'updates the note' do
            subject
            assert_equal PublisherNote.find(publisher_notes(:admin_note).id).note, "@hello test"
          end
        end

        describe 'when there is an error' do
          let(:note_params) do
            { publisher_note: { note: "" } }
          end

          before { subject }

          it 'does not update the note' do
            assert_equal PublisherNote.find(publisher_notes(:admin_note).id).note, publisher_notes(:admin_note).note
          end

          it 'does not create a note' do
            assert_equal flash[:alert], "Note can't be blank"
          end

          it 'redirects to the publisher page' do
            assert_redirected_to admin_publisher_path(publishers(:verified))
          end
        end
      end

      describe 'when the user was not the one who created the note' do
        let(:subject) do
          patch admin_publisher_publisher_note_path(
            id: publisher_notes(:note).id,
            publisher_id: publishers(:verified).id
          ), params: note_params
        end

        it 'raises an exception' do
          assert_raises { subject }
        end
      end
    end

    describe 'delete' do
      describe 'when the note is a thread' do
        let(:subject) do
          delete admin_publisher_publisher_note_path(
            id: publisher_notes(:thread_note).id,
            publisher_id: publishers(:verified).id
          )
        end

        before { subject }

        it 'does not allow the user to delete' do
          assert_equal flash[:alert], "Can't delete a note that has comments."
        end
      end

      describe 'when the user was not the one who created the note' do
        let(:subject) do
          delete admin_publisher_publisher_note_path(
            id: publisher_notes(:note).id,
            publisher_id: publishers(:verified).id
          ), params: note_params
        end

        it 'raises an exception' do
          assert_raises { subject }
        end
      end

      describe 'when the note was created by the user' do
        let(:subject) do
          delete admin_publisher_publisher_note_path(
            id: publisher_notes(:child_note).id,
            publisher_id: publishers(:just_notes).id
          )
        end

        before { subject }

        it 'redirects to the publisher page' do
          assert_redirected_to admin_publisher_path(publishers(:just_notes).id)
        end

        it 'deletes the note' do
          refute PublisherNote.find_by(id: publisher_notes(:child_note).id)
        end
      end
    end
  end
end
