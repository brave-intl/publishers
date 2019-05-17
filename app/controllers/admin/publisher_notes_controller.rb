module Admin
  class PublisherNotesController < AdminController
    before_action :authorize, except: :create

    def create
      publisher = Publisher.find(params[:publisher_id])
      admin = current_user

      note = PublisherNote.new(
        publisher: publisher,
        created_by: current_user,
        note: note_params[:note],
      )
      note.thread_id = note_params[:thread_id] if note_params[:thread_id].present?


      if note.save
        email_tagged_users(note)

        if note_params[:thread_id].present?
          created_by = PublisherNote.find(note_params[:thread_id]).created_by
          InternalMailer::tagged_in_note(
            tagged_user: created_by,
            note: note
          ).deliver_later unless current_user == created_by
        end

        redirect_to(admin_publisher_path(publisher.id))
      else
       redirect_to admin_publisher_path(publisher.id), flash: { alert: note.errors.full_messages.join(',') }
      end
    end

    def update
      if @note.update(note_params)
        email_tagged_users(@note)

        redirect_to admin_publisher_path(id: params[:publisher_id] ), flash: { success: "Successfully updated comment"}
      else
        redirect_to admin_publisher_path(id: params[:publisher_id]), flash: { alert: note.errors.full_messages }
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
      publisher_note.note.scan(/\@(\w*)/).each do |mention|
        # Some reason the regex likes to put an array inside array
        mention = mention[0]
        publisher = Publisher.where("email LIKE ?", "#{mention}@brave.com").first
        InternalMailer::tagged_in_note(tagged_user: publisher, note: publisher_note).deliver_later if publisher.present?
      end
    end

    def authorize
      @note =  PublisherNote.find(params[:id])
      raise unless @note.created_by == current_user
    end

    def note_params
      params.require(:publisher_note).permit(:note, :thread_id)
    end
  end
end
