module Admin
  class PublisherNotesController < AdminController
    before_action :authorize, except: :create

    EMAIL = "@brave.com"

    def create
      publisher = Publisher.find(params[:publisher_id])

      note = PublisherNote.new(
        publisher: publisher,
        created_by: current_user,
        note: note_params[:note],
      )
      note.thread_id = note_params[:thread_id] if note_params[:thread_id].present?

      if note.save
        email_tagged_users(note)

        if note_params[:thread_id].present?
          created_by = note.thread.created_by
          if current_user != created_by && note.note.exclude?("@" + created_by.email.sub(EMAIL, ''))
            InternalMailer.tagged_in_note(
              tagged_user: note.thread.created_by,
              note: note
            ).deliver_later
          end
        end

        redirect_to(admin_publisher_path(publisher.id))
      else
        redirect_to admin_publisher_path(publisher.id), flash: { alert: note.errors.full_messages.join(',') }
      end
    end

    def update
      if @note.update(note_params)
        email_tagged_users(@note)

        redirect_to admin_publisher_path(id: params[:publisher_id]), flash: { success: "Successfully updated comment" }
      else
        redirect_to admin_publisher_path(id: params[:publisher_id]), flash: { alert: @note.errors.full_messages.join(',') }
      end
    end

    def destroy
      publisher = @note.publisher
      if @note.comments.any?
        redirect_to admin_publisher_path(publisher), flash: { alert: "Can't delete a note that has comments." }
      else
        @note.destroy

        redirect_to admin_publisher_path(publisher)
      end
    end

    private

    def email_tagged_users(publisher_note)
      publisher_note.note.scan(/\@(\w*)/).uniq.each do |mention|
        # Some reason the regex likes to put an array inside array
        mention = mention[0]
        publisher = Publisher.where("email LIKE ?", mention + EMAIL).first
        InternalMailer.tagged_in_note(tagged_user: publisher, note: publisher_note).deliver_later if publisher.present?
      end
    end

    def authorize
      @note = PublisherNote.find(params[:id])
      raise unless @note.created_by == current_user
    end

    def note_params
      params.require(:publisher_note).permit(:note, :thread_id)
    end
  end
end
